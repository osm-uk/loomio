<script lang="coffee">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Records from '@/shared/services/records'

export default
  props:
    event: Object
    eventable: Object
    collapsed: Boolean

  computed:
    headline: ->
      actor = @event.actor()
      if @event.kind == 'new_comment' && @collapsed && @event.descendantCount > 0
        @$t('reactions_display.name_and_count_more', {name: actor.nameWithTitle(@eventable.group()), count: @event.descendantCount})
      else
        @$t eventHeadline(@event, true ), # useNesting
          author:   actor.nameWithTitle(@eventable.group())
          username: actor.username
          key:      @event.model().key
          title:    eventTitle(@event)
          polltype: @$t(eventPollType(@event)).toLowerCase()

    link: ->
      LmoUrlService.event @event

</script>

<template lang="pug">
h3.strand-item__headline.thread-item__title.body-2.pb-1(tabindex="-1" :id="'event-' + event.id")
  //- div
    | id: {{event.id}}
    | pos {{event.position}}
    | sid {{event.sequenceId}}
    | depth: {{event.depth}}
    | childCount: {{event.childCount}}
    | eid: {{event.eventableId}}
  div(v-if="eventable.discardedAt")
    span.grey--text(v-t="'thread_item.removed'")
    mid-dot
    router-link.grey--text(:to='link')
      time-ago(:date='eventable.discardedAt')
  div.d-flex.align-center(v-else)
    v-icon(v-if="event.pinned") mdi-pin
    slot(name="headline")
      span.strand-item__headline(v-html='headline')
    mid-dot
    router-link.grey--text.body-2(:to='link')
      time-ago(:date='event.createdAt')

</template>
<style lang="sass">
.strand-item__headline
  strong
    font-weight: 400
</style>
