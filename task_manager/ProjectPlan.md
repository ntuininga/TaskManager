# Project Plan

## General

- [x] Update Task with Date
- [] Update Task with Urgency
- [] Add Themes
- [x] Create New User in db
- [] Pull data only on load and pass into all widgets

## Screens

### Dashboard

- [x] Display Today's Tasks
- Stats
    - [x] Display remaining tasks uncompleted
    - [x] Display number of tasks completed today
    - [] Display number of tasks completed total

### Task Detail Screen

- Selectable Tasks
    - [x] Add on click functionality to task cards
    - [x] Navigate to detail page
- Detail Screen Start
    - [x] Display Task Name
    - [x] Display Task Description
    - [x] Display Task Category
    - [x] Display Task Date
    - [] Display Urgency
- Form Validation

### Task List Screen

- Update List Screen to Use Blocs
- Filter Buttons
    - [x] Buttons
    - [x] Filter by Date
    - [] Filter by Urgency 
    - [x] Filter by Category
    - [x] Display All (No Filter)
- [x] Add new Task uses TaskDataSource

### Settings Screen

- Dark Mode
- Clear Tasks
    - [x] Add Button to Clear tasks
    - [x] Create Database function to clear tasks
    - [x] Add functionality to clear tasks
    - [x] Confirm delete dialog 
    - [x] Update Task list screen on delete all tasks
- Change App Theme
    - [] Display all available themes
    - [] Update app theme on press
 
### Task Data

- [x] Task Urgency
- [x] Completed On Date
- [x] Created On Date


## Bugs & Fixes
- [x] Create new Task shouldn't require a category
- [] ? Make Delete all Tasks refresh smoother (Not Reload)
- [x] Remove new task bottom sheet when task dialog opened
- [x] Update Database with Date
- [] Update Database with urgency
- [] ? Task Entity includes Task Category as a property
- [x] Add UpdateTask to repository
- [] Fix Colours not changing on task list sort
- [x] Fix allow taps on today's tasks list
- [] No Boolean's in database

## Notes & Ideas

- Daily Tasks
- Repeatable Tasks
- Graphs
- Calendar
- Task Due Time
