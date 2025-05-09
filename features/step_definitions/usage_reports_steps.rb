When /^weekly reports are dispatched$/ do
  Pdf::Dispatch.weekly
end

When /^daily reports are dispatched$/ do
  Pdf::Dispatch.daily
end
