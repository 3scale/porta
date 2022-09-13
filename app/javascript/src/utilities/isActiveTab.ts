type TAB = 'metrics' | 'methods';

export const isActiveTab = (tab: TAB): boolean => new URL(window.location.href).searchParams.get('tab') === tab
