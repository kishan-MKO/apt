import 'package:cloud_firestore/cloud_firestore.dart';

import 'appointment.dart';

class FirestoreService {
    FirebaseFirestore _db = FirebaseFirestore.instance; 

    //Get Entries
    Stream<List<Appointment>> getEntries(){
      return _db
        .collection('entries')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromJson(doc.data()))
        .toList());
    }

    //Upsert
    Future<void> setEntry(Appointment entry){
      var options = SetOptions(merge:true);
      return _db
        .collection('entries')
        .doc(entry.entryId)
        .set(entry.toMap(),options);
    }

    //Delete
    Future<void> removeEntry(String entryId){
      return _db
        .collection('entries')
        .doc(entryId)
        .delete();
    }

}