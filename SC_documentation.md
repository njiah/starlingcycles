# Starling Cycles Flutter App Documentation
#### By Jiah Linn (23-24)
<br>

### Dart Files
Location: /lib <br>
1. **main**: running the app, bottom navigation bar linking to pages 
2. **home**: home page, add a new batch form 
3. **database**: database connection, database helper and instances 
4. **batchpage**: frames table (get there by clicking on a batch or adding a new batch)
5. **progresspage**: table of process for each batch (get there by clicking start on a batch)
6. **batches**: display of existing batches in three tabs ('not started', 'in progress', 'completed')
7. **addbatch**: form to add batches, display located in home
8. **settingspage** : Manufacture types and processes in containers with CRUD actions
9. **addManufacture** : add a new manufacturetype page with drag and drop feature and add a new process form
10. **manufacture** : displays list of batches of the manufacture type and delete if no batches are in-progress

<br>

### Public Spec
Contains the versions of the libraries used.

<br>

### Assets
* database storage
* logo image in /images

### Location of APKs
* build/app/outputs/flutter-apk/*