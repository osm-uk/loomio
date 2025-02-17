<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import FlashService   from '@/shared/services/flash'
import EventBus from '@/shared/services/event_bus'
import { snakeCase } from 'lodash'

export default
  props:
    membership: Object
  methods:
    canPerformAction: ->
      @canSetTitle()         or
      @canRemoveMembership() or
      @canResendMembership() or
      @canToggleAdmin()

    canSetTitle: ->
      AbilityService.canSetMembershipTitle(@membership)

    setTitle: ->
      EventBus.$emit 'openModal',
                      component: 'MembershipModal',
                      props:
                        membership: @membership.clone()

    canResendMembership: ->
      AbilityService.canResendMembership(@membership)

    resendMembership: ->
      FlashService.loading()
      @membership.resend().then ->
        FlashService.success "membership_dropdown.invitation_resent"

    canRemoveMembership: ->
      AbilityService.canRemoveMembership(@membership)

    removeMembership: ->
      namespace = if @membership.acceptedAt then 'membership' else 'invitation'

      messages = []
      messages.push @$t("membership_remove_modal.#{namespace}.message", { name: @membership.user().name })

      if @membership.group().parentId
        messages.push @$t("membership_remove_modal.membership.impact_for_subgroup")
      else
        messages.push @$t("membership_remove_modal.membership.impact_for_group")

      EventBus.$emit 'openModal',
                      component: 'ConfirmModal',
                      props:
                        confirm:
                          membership: @membership.clone()
                          text:
                            title:    "membership_remove_modal.#{namespace}.title"
                            raw_helptext: messages.join('<br>')
                            flash:    "membership_remove_modal.#{namespace}.flash"
                            submit:   "membership_remove_modal.#{namespace}.submit"
                          submit:     @membership.destroy
                          redirect:   ('dashboard' if @membership.user() == Session.user())

    canToggleAdmin: ->
      (@membership.group().adminMembershipsCount == 0 and @membership.user() == Session.user()) or
      (AbilityService.canAdminister(@membership.group()) and (!@membership.admin or @canRemoveMembership(@membership))) or
      (@membership.userIs(Session.user()) && @membership.group().parentOrSelf().adminsInclude(Session.user()))


    toggleAdmin: (membership) ->
      method = if @membership.admin then 'removeAdmin' else 'makeAdmin'
      return if @membership.admin and @membership.user() == Session.user() and !confirm(@$t('memberships_page.remove_admin_from_self.question'))
      Records.memberships[method](@membership).then =>
        FlashService.success "memberships_page.messages.#{snakeCase method}_success", name: (@membership.userName() || @membership.userEmail())
</script>

<template lang="pug">
.membership-dropdown.lmo-no-print(v-if='canPerformAction()')
  v-menu.lmo-dropdown-menu(offset-y)
    template(v-slot:activator="{on, attrs}")
      v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
        //- span(v-t="'membership_dropdown.membership_options'")
        v-icon mdi-dots-vertical
    v-list.group-actions-dropdown__menu-content
      v-list-item.membership-dropdown__set-title(v-if='canSetTitle()' @click='setTitle()')
        v-list-item-title(v-t="'membership_dropdown.set_title'")
      v-list-item.membership-dropdown__resend(v-if='canResendMembership()' @click='resendMembership()', :disabled='membership.resent')
        v-list-item-title(v-t="'membership_dropdown.resend'", v-if='!membership.resent')
        v-list-item-title(v-t="'membership_dropdown.invitation_resent'", v-if='membership.resent')
      v-list-item.membership-dropdown__toggle-admin(v-if='canToggleAdmin()' @click='toggleAdmin()')
        v-list-item-title(v-t="'membership_dropdown.make_coordinator'", v-if='!membership.admin')
        v-list-item-title(v-t="'membership_dropdown.demote_coordinator'", v-if='membership.admin')
      v-list-item.membership-dropdown__remove(v-if='canRemoveMembership()' @click='removeMembership()')
        v-list-item-title(v-if='membership.acceptedAt' v-t="'membership_dropdown.remove_from.group'")
        //- v-list-item-title(v-if='membership.acceptedAt')
        //-   span "remove membership"
        v-list-item-title(v-t="'membership_dropdown.cancel_invitation'", v-if='!membership.acceptedAt')
</template>
