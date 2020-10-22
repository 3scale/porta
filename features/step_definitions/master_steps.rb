# frozen_string_literal: true

Given "the master account allows signups" do
  master_account # Ensure that the master account exists, otherwise it creates it
  step 'provider "master" has multiple applications disabled'
  step 'provider "master" has default service and account plan'
  step 'a default application plan "Base" of provider "master"'
end
