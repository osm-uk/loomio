module Null::User
  # include HasAvatar
  include Null::Object
  def can?(*args)
    ability.can?(*args)
  end

  def ability
    @ability ||= Ability::Base.new(self)
  end

  def nil_methods
    [:id, :key, :username, :short_bio, :city, :region, :country, :selected_locale, :deactivated_at, :time_zone,
     :default_membership_volume, :unsubscribe_token, :slack_identity, :location,
     :encrypted_password, :update_attribute, :last_seen_at, :legal_accepted_at]
  end

  def false_methods
    [:is_logged_in?, :is_member_of?, :is_admin_of?, :is_admin?, :is_admin, :uses_markdown?,
     :email_when_proposal_closing_soon, :email_catch_up, :has_password, :bot,
     :email_when_mentioned, :email_on_participation, :email_verified, :email_verified?, :email_newsletter, :marked_for_destruction?]
  end

  def empty_methods
    [:group_ids, :adminable_group_ids, :group_ids, :attachments, :guest_discussion_ids]
  end

  def hash_methods
    [:experiences]
  end

  def none_methods
    {
      notifications: :notification,
      login_tokens: :login_token,
      memberships: :membership,
      admin_memberships: :membership,
      participated_polls: :poll,
      group_polls: :poll,
      polls: :poll,
      stances: :stance,
      groups: :group
    }
  end

  def short_bio_format
    "html"
  end

  def identities
    Identities::Base.none
  end

  def is_admin?
    false
  end
end
