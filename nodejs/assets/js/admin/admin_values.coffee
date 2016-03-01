app = angular.module 'vtValues', []
app.value 'timeUnits',
    year: '年'
    month: '月'
    week: '周'
    day: '日'
    numOfDaysInAWeek: 7
app.value 'adminViewIndex',
    'dashboard': 1
    'user': 2
    'schedule': 3
# bulk action options
app.value 'actionOptions', [
    value: 1, name: 'Delete'
]
app.value 'listTypes', [
    {'index': 1, 'name': 'All results'}
    {'index': 2, 'name': 'Search results'}
    {'index': 3, 'name': 'Sorted'}
    {'index': 4, 'name': 'Time range'}
]