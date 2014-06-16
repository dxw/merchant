#!/usr/bin/env bundle exec ruby

require 'rubygems'
require 'active_merchant'
require 'slop'
require 'pry'

class Merchant
  attr_reader :opts

  def initialize
    ActiveMerchant::Billing::Base.mode = :test

    @opts = Slop.parse(help: true) do
      banner 'Usage: merchant.rb [options]'

      # Method
      on '-method=', 'method', "Chosen function [ purchase, store ]"
      on '-params=', 'params', "Parameters"

      # Authentication
      on '-pspid=', 'login', "Login"
      on '-user=', 'user_name', "Ogone username"
      on '-pass=', 'password', "Ogone password"

      # Card details
      on '-fn=', 'first_name', "First name"
      on '-ln=', 'last_name', "Last name"
      on '-cn=', 'card_number', "Card number"
      on '-ct=', 'card_type', "Card type"
      on '-m=', 'month', "Expiry month"
      on '-y=', 'year', "Expiry year"
      on '-v=', 'verification_value', "Verification value"

      # Payment
      on '-a=', 'amount', "Amount to pay (100 = £1)"
    end

    begin
      send(@opts[:method])
    rescue
      raise NoMethodError
    end
  end

  def store
    if credit_card.valid?
      response = ogonegateway.store(credit_card, billing_id: reference, currency: "GBP")

      if response.success?
        puts "Successfully stored details under the '#{reference}' alias"
      else
        raise StandardError, response.message
      end
    end
  end

  def purchase
    if credit_card.valid?
      response = ogonegateway.purchase(amount, credit_card, currency: "GBP")

      if response.success?
        puts "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
      else
        raise StandardError, response.message
      end
    end
  end

  private
  # Trusted by default
  def gateway
    @gateway ||= ActiveMerchant::Billing::TrustCommerceGateway.new(login: 'TestMerchant', password: 'password')
  end

  # DirectLink gateway authenticated with an ePDQ user
  def ogonegateway
    @gateway ||= ActiveMerchant::Billing::OgoneGateway.new(
      :login               => opts[:pspid],
      :user                => opts[:user],
      :password            => opts[:pass],
      # :signature           => "",                   # SHA-IN - must match ePDQ account configuration
      :signature_encryptor => "none"                  # Can be "none" (default), "sha1", "sha256" or "sha512".
                                                      # Must be the same as the one configured in your Ogone account.
    )
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :first_name         => opts[:fn],
      :last_name          => opts[:ln],
      :number             => opts[:cn],
      :brand              => opts[:ct],
      :month              => opts[:month],
      :year               => opts[:year],
      :verification_value => opts[:verification_value]
    )
  end

  def amount
    @amount ||= opts[:amount].to_i
  end

  def reference
    @amount ||= opts[:params] || "example_reference"
  end
end

Merchant.new
