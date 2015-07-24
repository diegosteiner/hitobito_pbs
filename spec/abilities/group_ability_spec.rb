# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'


describe GroupAbility do

  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }


  context 'mitarbeiter gs' do
    let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

    context 'in bund' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:bund))
      end
    end

    context 'in kanton' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end

  context 'kantonsleitung' do
    let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)) }

    context 'in kanton' do
      it 'may not modify superior attributes' do
        is_expected.not_to be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may not modify superior attributes' do
        is_expected.not_to be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end

  context 'education' do
    def ability(name, role)
      group = groups(name)
      Ability.new(Fabricate("#{group.class.name}::#{role}", group: group).person)
    end

    context :layer_and_below_full do
      it 'may show education in layer group' do
        expect(ability(:bund, "MitarbeiterGs")).to be_able_to(:education, groups(:bund))
      end

      it 'may show education in layer below' do
        expect(ability(:bund, "MitarbeiterGs")).to be_able_to(:education, groups(:be))
      end

      it 'may not show education in group below' do
        expect(ability(:be, "Kantonsleitung")).not_to be_able_to(:education, groups(:fg_security))
      end

      it 'may not show education in upper layer' do
        expect(ability(:be, "Kantonsleitung")).not_to be_able_to(:education, groups(:bund))
      end
    end

    context :layer_full do
      it 'may show education in layer group' do
        expect(ability(:bund, "AssistenzAusbildung")).to be_able_to(:education, groups(:bund))
      end

      it 'may not show education in layer below' do
        expect(ability(:bund, "AssistenzAusbildung")).not_to be_able_to(:education, groups(:be))
      end

      it 'may not show education in group below' do
        expect(ability(:be, "VerantwortungAusbildung")).not_to be_able_to(:education, groups(:fg_security))
      end

      it 'may not show education in upper layer' do
        expect(ability(:be, "VerantwortungAusbildung")).not_to be_able_to(:education, groups(:bund))
      end
    end
  end


end
