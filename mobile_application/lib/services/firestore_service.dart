import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final CollectionReference _portMapping = FirebaseFirestore.instance.collection('port_mapping');
  final CollectionReference _cronJob = FirebaseFirestore.instance.collection('cron_jobs');

  // Get port mapping
  Stream<QuerySnapshot> getPortMappings() {
    return _portMapping.orderBy('index', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getCronJobs(String key) {
    return _cronJob.where('port_key', isEqualTo: key).orderBy('hour', descending: false).orderBy('min', descending: false).snapshots();
  }

  Future<void> updatePortMap(String key, Map<String, Object> data) {
    return _portMapping.doc(key).update(data);
  }

  Stream<DocumentSnapshot> getPort(String key) {
    return _portMapping.doc(key).snapshots();
  }

  Future<DocumentReference<Object?>> createTimer(Object data) {
    return _cronJob.add(data);
  }

  Future<void> updateTimer(String key, Map<String, Object> data) {
    return _cronJob.doc(key).update(data);
  }

  Future<void> deleteCronJob(String key) {
    return _cronJob.doc(key).delete();
  }


}