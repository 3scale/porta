class FillInNewFinanceFields < ActiveRecord::Migration
  def self.up
    puts "Updating Invoices"    
    Invoice.find_each do |invoice|
      # yes, calling 3 updates is inefficient
      update_period(invoice)
      update_date_fields(invoice)
      update_state(invoice)
      putc '.'
    end

    puts "Updating PeriodicFeeLineItem"
    PeriodicFeeLineItem.find_each do |item|
      item.started_at = item.created_at
      item.save(false)
      putc '.'
    end
  end

  def self.down
  end

  private

  def self.update_period(invoice)
    invoice.period = Month.new(invoice.created_at)
    invoice.save(false)
  end
  
  def self.update_date_fields(invoice)
    today = Time.zone.today
    
    if invoice.period.end.to_date < today      
      invoice.issued_on = (invoice.created_at + 1.month).beginning_of_month
      invoice.due_on = invoice.issued_on + 6.days
    else
      invoice.issued_on = nil
      invoice.due_on = nil
    end

    invoice.save(false)
  end

  
  # WAR IS HELL!
  def self.update_state(invoice)   
    today = Time.zone.today

    if invoice.issued_on
      invoice.state = :pending
      
      if invoice.cost == 0
        invoice.state = :paid
        invoice.paid_at = invoice.issued_on
      elsif invoice.paid_at
        invoice.state = :paid 
      else
        if invoice.due_on + 8.days > today
          invoice.state = :unpaid
        else
          invoice.state = :failed
        end
      end
    else
      invoice.state = :open
    end

    invoice.save!
  end
  

end
