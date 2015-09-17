#KVStore

##Description:
Demonstrates the use of DatabaseManger - Key/Value storage layer.

##How to Use:
- Launch the application. A alert will be shown about the database initialization on the main screen(Title: KVStore) only if DatabaseManger fails to initialize.
- Select the Add button(+) on the navigation bar to add records.
- "Add New Record" screen will be shown. On this screen enter the "Employee" details to store in database. Here "Employee ID" will act as key in database and the Employee object as value.
- Hit the "Save Record" button to save record.
- Come back to main screen. The added record will be populated on the table view.
- Swipe rows to "DELETE" records. Demonstrates the implementation of "removeObjectForKey" API.
- Use search bar to "Search" a particular record with employeeID key. Demonstrates the implementation of "objectForKey" API.

##DatabaseManger
- This class acts as a SQLite Key/Value storage layer.
- NOTE: To save any object in database the obejct class has to impelemnnt "initWithCoder:", "encodeWithCoder:" and should conform to "NSCoding" protocol. These methods are used to archive an object.
- I have added comments for each of the API's in this class. Please refer "DatabaseManger.h" file.

##Unit Testing
- All the test cases for DatabaseManger API's are written in "TestDataBase.m"


