<script lang="coffee">
import Records  from '@/shared/services/records'
import AppConfig  from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'
import {uniq, without, isEqual} from 'lodash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    poll: Object
    close: Function

  data: ->
    originalLength: @poll.pollOptionNames.length
    isDisabled: false

  methods:
    submit: ->
      # there's a race condition here because of the way we are adding poll form options
      # hence the setTimeout
      setTimeout =>
        @poll.addOptions()
        .then =>
          @poll.removeOrphanOptions()
          Flash.success "poll_common_add_option.form.options_added"
          @close()
        .catch onError(@poll)

</script>

<template lang="pug">
v-card.poll-common-add-option-modal
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.headline(tabindex="-1" v-t="'poll_common_add_option.modal.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    poll-common-form-options-field(:poll="poll" v-if="poll.pollType != 'meeting'" add-options-only)
    poll-meeting-form-options-field(:poll="poll" v-if="poll.pollType == 'meeting'" add-options-only)
  v-card-actions
    v-spacer
    v-btn.poll-add-option__submit(color="primary" :disabled="poll.pollOptionNames.length == originalLength" @click='submit()' :loading="poll.processing")
      span(v-t="'poll_common_add_option.form.add_options'")
</template>
