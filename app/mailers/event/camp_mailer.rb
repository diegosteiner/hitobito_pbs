# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::CampMailer < ApplicationMailer

  CONTENT_CAMP_CREATED = 'camp_created'.freeze
  CONTENT_COACH_ASSIGNED = 'camp_coach_assigned'.freeze
  CONTENT_SECURITY_ADVISOR_ASSIGNED = 'camp_security_advisor_assigned'.freeze
  CONTENT_AL_ASSIGNED = 'camp_al_assigned'.freeze
  CONTENT_SUBMIT_REMINDER = 'camp_submit_reminder'.freeze
  CONTENT_SUBMIT = 'camp_submit'.freeze
  CONTENT_PARTICIPANT_APPLIED = 'camp_participant_applied'.freeze
  CONTENT_PARTICIPANT_CANCELED = 'camp_participant_canceled'.freeze

  attr_reader :camp

  def camp_created(camp, recipients, user_id)
    @camp = camp
    compose(recipients,
            CONTENT_CAMP_CREATED,
            'actuator-name' => Person.find(user_id).to_s)
  end

  def advisor_assigned(camp, advisor, key, user_id)
    @camp = camp
    compose(advisor,
            fetch_advisor_content_key(key),
            'actuator-name' => Person.find(user_id).to_s,
            'advisor-name' => advisor.to_s)
  end

  def remind(camp, recipient)
    @camp = camp
    compose(recipient,
            CONTENT_SUBMIT_REMINDER,
            'recipient-name' => recipient.greeting_name,
            'recipient-name-with-salutation' => recipient.salutation_value)
  end

  def submit_camp(camp)
    @camp = camp

    recipients = [Settings.email.camp.submit_recipient]
    recipients << Settings.email.camp.submit_abroad_recipient if camp.abroad?

    copies = [camp.coach,
              camp.abteilungsleitung,
              *camp.participations_for(Event::Camp::Role::Leader).collect(&:person)].compact

    compose(recipients,
            CONTENT_SUBMIT,
            { 'coach-name' => camp.coach.to_s, 'camp-application-url' => camp_application_url },
            cc: Person.mailing_emails_for(copies))
  end

  def participant_applied_info(participation, recipients)
    @camp = participation.event
    compose(recipients,
            CONTENT_PARTICIPANT_APPLIED,
            'participant-name' => participation.person.to_s)
  end

  def participant_canceled_info(participation, recipients)
    @camp = participation.event
    compose(recipients,
            CONTENT_PARTICIPANT_CANCELED,
            'participant-name' => participation.person.to_s)
  end

  private

  def compose(recipients, content_key, values, headers = {})
    values['camp-name'] = camp.name
    values['camp-url'] = camp_url
    values['camp-state'] = camp_state

    custom_content_mail(recipients, content_key, values, headers)
  end

  def camp_url
    link_to(group_event_url(camp.groups.first, camp))
  end

  def camp_application_url
    link_to(camp_application_group_event_url(camp.groups.first, camp))
  end

  def camp_state
    I18n.t("activerecord.attributes.event/camp.states.#{camp.state}")
  end

  def fetch_advisor_content_key(advisor_key)
    case advisor_key
    when 'coach' then CONTENT_COACH_ASSIGNED
    when 'abteilungsleitung' then CONTENT_AL_ASSIGNED
    else
      CONTENT_SECURITY_ADVISOR_ASSIGNED
    end
  end
end
