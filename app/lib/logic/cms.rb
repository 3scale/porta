# frozen_string_literal: true

# -*- coding: utf-8 -*-
module Logic
  module CMS
    module Provider
      extend ActiveSupport::Concern

      included do
        with_options(foreign_key: :provider_id) do |cms|
          # TODO: remove the CMS::LegalTerm condition when DB are cleaned (see test/functional/.../changes_controller_test.rb)
          cms.has_many :templates, -> { where.not(type: 'CMS::LegalTerm') }, class_name: 'CMS::Template', dependent: :delete_all
          cms.has_many :sections,             class_name: 'CMS::Section',
                        extend: ::CMS::Section::ProviderAssociationExtension, dependent: :delete_all

          cms.has_many :builtin_sections,     class_name: 'CMS::Builtin::Section',
                        extend: ::CMS::Section::ProviderAssociationExtension

          cms.has_many :provided_sections,    class_name: 'CMS::Section', dependent: :delete_all
          cms.has_many :redirects,            class_name: 'CMS::Redirect', dependent: :delete_all
          cms.has_many :files,                class_name: 'CMS::File', dependent: :delete_all
          cms.has_many :pages,                class_name: 'CMS::Page'
          cms.has_many :layouts,              class_name: 'CMS::Layout',
                        extend: ::CMS::Layout::ProviderAssociationExtension

          cms.has_many :builtins,             class_name: 'CMS::Builtin'
          cms.has_many :builtin_pages,        class_name: 'CMS::Builtin::Page',
                        extend: ::CMS::Builtin::Page::ProviderAssociationExtension, dependent: :delete_all

          cms.has_many :builtin_static_pages, class_name: 'CMS::Builtin::StaticPage'
          cms.has_many :builtin_partials,     class_name: 'CMS::Builtin::Partial'
          cms.has_many :builtin_legal_terms,  class_name: 'CMS::Builtin::LegalTerm',
                        extend: ::CMS::Builtin::LegalTerm::ProviderAssociationExtension

          # type condition prevents from loading builtin partials in this association
          cms.has_many :partials, -> { where(type: 'CMS::Partial') }, class_name: 'CMS::Partial'
          cms.has_many :all_partials,         class_name: 'CMS::Partial'
          cms.has_many :portlets,             class_name: 'CMS::Portlet'

          cms.has_many :provided_groups,      class_name: 'CMS::Group', dependent: :delete_all
          cms.has_many :email_templates,      class_name: 'CMS::EmailTemplate',
                        extend: ::CMS::EmailTemplate::ProviderAssociationExtension
        end

        after_create :create_cms_assets, if: :provider?
      end

      # TODO: cover by tests
      def john_doe_still_here?
        if john = self.buyer_users.find_by_username('john')
          john.authenticated?('123456')
        end
      end

      # TODO: cover by tests (and make it smarter)
      def cms_toolbar_intro_visible?
        # main_layout = self.layouts.find_by_system_name('main_layout')
        # (main_layout.try(:versions).try(:count) == 0) || false
        14.days.ago < self.created_at
      end

      def create_cms_assets
        self.builtin_sections.create!(title: 'Root', system_name: 'root', parent_id: nil)
        # TODO: add SimpleLayout logic here
      end
    end
  end
end
