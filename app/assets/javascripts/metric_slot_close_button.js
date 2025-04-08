/**
 * Handles close button from partials pricing_rules and usage_limits.
 */
document.addEventListener('DOMContentLoaded', () => {
  $(document).on('click', '.metric_slot_close_button', () => {
    $('.metrics-subtable-toggle.selected').removeClass('selected');
    $('.metric_slot, .plans_widget').remove();
    return false;
  });
})
