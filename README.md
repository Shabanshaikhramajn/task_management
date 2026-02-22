# task_management
 Task Management App
## Getting Started
# Flutter version 3.10.8

<!-- Future.delayed is used everywhere to simulate delays and observer state management-->

A Fluter-based Task

A Flutter-based Task Management App that allows users to create, edit, filter, and search tasks with offline-first support and sync capabilities. The app demonstrates clean architecture,clean state management, and robust handling of task synchronization.

---------------------------------------------------------------------------------------------
Architecture
The app contais main three layers 
Presentation layer -> incluing UI, events and state

Domain layer       -> Task entity represents entity data
                      Use case like SaveTaskUseCase handle business logic

Data layer         -> TaskRepository abstracts data source (localDB)

Benefits: 
          Seperation of concerns
          Includes large test coverage
          Easy to extends features


lib/
├── core/
│   ├── logger/
│   ├── router/
│   └── utils/
├── domain/
│   ├── entities/
│   └── usecases/
├── data/
│   ├── repositories/
│   └── datasources/
├── presentation/
│   ├── screens/
│   ├── bloc/
│   │   ├── task_bloc/
│   │   └── task_form_bloc/
│   └── widgets/
└── main.dart


---------------------------------------------------------------------------------------------
State Management
Bloc -> Bloc state mangement is used here for large architecture and seperation of concerns via domain layer
        Bloc helps handle and manage the state efficiently and easily fits in the large architecture as compare to getX and provider


---------------------------------------------------------------------------------------------
Conflict Resolution Technique  =>
        Tasks maintain a SyncStatus: synced, pendingSync

When multiple updates occur for the same task:

The latest update timestamp is used to resolve conflicts

Pending changes are marked as pendingSync

Upon successful sync, status is updated to synced

UI always shows the latest local changes while syncing

---------------------------------------------------------------------------------------------
Assumption made =>
   1. When app opens it fetched locally stored data with loading state
   2. It fetched only 6-7 records only initially and then support lazy loading as user scrolls showing circular loader
   3. user can use both search query and task status filter simultaneously and along with that it will also support the lazy loading
   4. after adding the task it gets synced withing 10 seconds with 70 percent of success probability, also applifecycle methods are also
      handled to ensure background sync
   5. user can update the tasks making the update time entry if previous value and current values are same then shown customtoast to  user that no changed detected
   6.used Hive as an local storage along  with build_runner so the data can be directly stored from the model to local storage, no need to write any extra quries
   7. pull to refresh also used so the user can refetch the data
   8.logging layer is also used to check the logs and save time from debugging


---------------------------------------------------------------------------------------------

 Dependencies =>

        flutter_bloc – State management

        go_router – Navigation

        uuid – Task ID generation

        Hive - local persistent storage

        build_runner - code generation and boilerplae creation for hive models

        get_it - dependency injection

        logger - easy logging

