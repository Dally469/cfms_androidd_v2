import 'package:cfms/models/donation_record_model.dart';
import 'package:cfms/models/offering_records_model.dart';
import 'package:cfms/models/quick_payment_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../models/cache_model.dart';
import '../../models/donations/category_model.dart';
import '../../models/local_member_model.dart';

class DbHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _dbName = 'sdacfms.db';

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }

    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE offerings (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, translation TEXT)');
    await db.execute(
        'CREATE TABLE cached_data (url TEXT PRIMARY KEY, data TEXT, saved_at INT, extra TEXT)');
    await db.execute(
        'CREATE TABLE donation (id INTEGER PRIMARY KEY AUTOINCREMENT, donationId VARCHAR UNIQUE, donationName VARCHAR, amount INTEGER)');
    await db.execute(
        'CREATE TABLE offering_records (id INTEGER PRIMARY KEY AUTOINCREMENT, memberId VARCHAR, offeringId VARCHAR, narration VARCHAR, churchCode VARCHAR, amount VARCHAR, createdAt VARCHAR)');
    await db.execute(
        'CREATE TABLE quick_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, phone VARCHAR, offerings TEXT, churchId VARCHAR, totalAmount VARCHAR, currency VARCHAR, createdAt VARCHAR, synced BOOLEAN DEFAULT 0)');
    await db.execute(
        'CREATE TABLE members (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, phone VARCHAR UNIQUE, churchCode VARCHAR)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    if (oldVersion < newVersion) {
      // Example: if (oldVersion == 1) {
      //   await db.execute('ALTER TABLE members ADD COLUMN email TEXT');
      // }
    }
  }

  // Cache operations
  Future<bool> saveCache(CacheModel cacheModel) async {
    var dbClient = await db;
    await dbClient!.insert('cached_data', cacheModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace // Handle duplicate URLs
        );
    return true;
  }

  Future<void> clearCache() async {
    var dbClient = await db;
    await dbClient!.delete('cached_data');
  }

  Future<List<CacheModel>?> getCachedData(String url) async {
    final dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!
        .query('cached_data', where: 'url = ?', whereArgs: [url]);
    if (queryResult.isEmpty) {
      return null;
    }
    return queryResult.map((e) => CacheModel.fromJson(e)).toList();
  }

  // Member operations
  Future<int> insertMember(MemberLocalModel memberLocalModel) async {
    var dbClient = await db;

    // Check if member exists with same phone
    final existing = await dbClient!.query('members',
        where: 'phone = ?', whereArgs: [memberLocalModel.phone]);

    if (existing.isNotEmpty) {
      // Update existing record
      return await dbClient.update('members', memberLocalModel.toJson(),
          where: 'phone = ?', whereArgs: [memberLocalModel.phone]);
    } else {
      // Insert new record
      return await dbClient.insert('members', memberLocalModel.toJson());
    }
  }

  // Offering record operations
  Future<int> createRecord(OfferingRecordModel offeringRecordModel) async {
    var dbClient = await db;
    try {
      final insertedId = await dbClient!.insert(
          'offering_records', offeringRecordModel.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return insertedId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating offering record: $e');
      }
      return -1;
    }
  }

  // Quick payment operations
  Future<int> quickPaymentAdd(QuickPaymentModel quickPaymentModel) async {
    var dbClient = await db;
    try {
      // Add synced status to track which records have been uploaded
      final Map<String, dynamic> data = quickPaymentModel.toJson();
      data['synced'] = 0; // 0 means not synced

      final insertedId = await dbClient!.insert('quick_payments', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return insertedId;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding quick payment: $e');
      }
      return -1;
    }
  }

  Future<int> markQuickPaymentAsSynced(int id) async {
    var dbClient = await db;
    return await dbClient!.update('quick_payments', {'synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSyncedQuickPayment(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete('quick_payments', where: 'id = ?', whereArgs: [id]);
  }

  // Other deletion operations
  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('donation', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRecords(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete('donation_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var dbClient = await db;
    return await dbClient!.delete('donation');
  }

  Future<int> deleteRecordAll() async {
    var dbClient = await db;
    return await dbClient!.delete('donation_records');
  }

  // Query operations
  Future<List<DonationsModel>> getDonationList() async {
    final dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('donation');
    return queryResult.map((e) => DonationsModel.fromJson(e)).toList();
  }

  Future<List<MemberLocalModel>> getMemberList() async {
    final dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('members');
    return queryResult.map((e) => MemberLocalModel.fromJson(e)).toList();
  }

  Future<List<QuickPaymentModel>> getLocalCashReceipt(
      {bool syncedOnly = false}) async {
    final dbClient = await db;
    final List<Map<String, Object?>> queryResult = syncedOnly
        ? await dbClient!.query('quick_payments', where: 'synced = 1')
        : await dbClient!.query('quick_payments');

    return queryResult.map((e) => QuickPaymentModel.fromJson(e)).toList();
  }

  Future<List<QuickPaymentModel>> getUnsyncedPayments() async {
    final dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('quick_payments', where: 'synced = 0');

    return queryResult.map((e) => QuickPaymentModel.fromJson(e)).toList();
  }

  Future<List<DonationRecordModel>> getDonationRecords() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('donation_records', orderBy: 'id DESC');
    return queryResult.map((e) => DonationRecordModel.fromJson(e)).toList();
  }

  Future<List<DonationRecordModel>> getRecordByDate(String selectDate) async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query(
        'donation_records',
        where: 'createdAt = ?',
        whereArgs: [selectDate],
        orderBy: 'id DESC');

    return queryResult.map((e) => DonationRecordModel.fromJson(e)).toList();
  }
}
