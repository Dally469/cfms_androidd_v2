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

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }

    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'sdacfms.db');
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE offerings (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, translation TEXT)');
    await db.execute(
        'CREATE TABLE cached_data (url TEXT PRIMARY KEY, data TEXT, saved_at INT, extra TEXT)');
    await db.execute(
        'CREATE TABLE donation (id INTEGER PRIMARY KEY AUTOINCREMENT, donationId VARCHAR UNIQUE, donationName VARCHAR, amount INTEGER)');
    await db.execute(
        'CREATE TABLE offering_records (id INTEGER PRIMARY KEY AUTOINCREMENT,memberId VARCHAR, offeringId VARCHAR, narration VARCHAR, churchCode VARCHAR, amount VARCHAR, createdAt VARCHAR)');
    await db.execute(
        'CREATE TABLE quick_payments (id INTEGER PRIMARY KEY AUTOINCREMENT,name VARCHAR,phone VARCHAR, offerings TEXT, churchId VARCHAR, totalAmount VARCHAR, currency VARCHAR, createdAt VARCHAR)');
    await db.execute(
        'CREATE TABLE members (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, phone VARCHAR UNIQUE , churchCode VARCHAR)');
  }

  Future<bool> saveCache(CacheModel cacheModel) async {
    var dbMember = await db;
    await dbMember!.insert('cached_data', cacheModel.toJson());
    return true;
  }

  Future<void> clearCache() async {
    var dbMember = await db;
    await dbMember!.delete('cached_data');
  }

  Future<List<CacheModel>?> getCachedData(String url) async {
    final dbMember = await db;
    final List<Map<String, Object?>> queryResult = await dbMember!
        .query('cached_data', where: 'url = ?', whereArgs: [url]);
    if (queryResult.isEmpty) {
      return null;
    }
    return queryResult.map((e) => CacheModel.fromJson(e)).toList();
  }

  Future<int> insertMember(MemberLocalModel memberLocalModel) async {
    var dbMember = await db;
    final insertedId = await dbMember!.insert(
      'members',
      memberLocalModel.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return insertedId;
  }

  Future<int> createRecord(OfferingRecordModel offeringRecordModel) async {
    var dbMember = await db;
    final insertedId = await dbMember!
        .insert('offering_records', offeringRecordModel.toJson());
    if (kDebugMode) {
      print(insertedId);
    }
    return insertedId;
  }

  Future<int> quickPaymentAdd(QuickPaymentModel quickPaymentModel) async {
    var dbMember = await db;
    try {
      final insertedId =
          await dbMember!.insert('quick_payments', quickPaymentModel.toJson());
      if (kDebugMode) {
        print(insertedId);
      }
      return insertedId;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0;
    }
  }

  Future<int> deleteSyncedQuickPayment(int id) async {
    var dbMember = await db;
    final deletedId = await dbMember!
        .delete('quick_payments', where: 'id = ?', whereArgs: [id]);
    return deletedId;
  }

  Future<int> delete(int id) async {
    var dbMember = await db;
    return await dbMember!.delete('donation', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRecords(int id) async {
    var dbMember = await db;
    return await dbMember!
        .delete('donation_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var dbMember = await db;
    return await dbMember!.delete('donation');
  }

  Future<int> deleteRecordAll() async {
    var dbMember = await db;
    return await dbMember!.delete('donation_records');
  }

  Future<List<DonationsModel>> getDonationList() async {
    final dbMember = await db;
    final List<Map<String, Object?>> queryResult =
        await dbMember!.query('donation');
    return queryResult.map((e) => DonationsModel.fromJson(e)).toList();
  }

  Future<List<MemberLocalModel>> getMemberList() async {
    final dbMember = await db;
    final List<Map<String, Object?>> queryResult =
        await dbMember!.query('members');
    if (kDebugMode) {
      print(queryResult);
    }
    return queryResult.map((e) => MemberLocalModel.fromJson(e)).toList();
  }

  Future<List<QuickPaymentModel>> getLocalCashReceipt() async {
    final dbMember = await db;
    final List<Map<String, Object?>> queryResult =
        await dbMember!.query('quick_payments');
    if (kDebugMode) {
      print("MYLOCAL");
      print(queryResult);
    }
    return queryResult.map((e) => QuickPaymentModel.fromJson(e)).toList();
  }

  Future<List<DonationRecordModel>> getDonationRecords() async {
    var dbRecord = await db;
    final List<Map<String, Object?>> queryResult =
        await dbRecord!.query('donation_records', orderBy: 'id DESC');
    return queryResult.map((e) => DonationRecordModel.fromJson(e)).toList();
  }

  Future<List<DonationRecordModel>> getRecordByDate(String selectDate) async {
    var dbRecord = await db;
    final List<Map<String, Object?>> queryResult = await dbRecord!.query(
        'donation_records',
        where: 'createdAt = ?',
        whereArgs: [selectDate],
        orderBy: 'id DESC');
    if (kDebugMode) {
      print(queryResult);
    }
    return queryResult.map((e) => DonationRecordModel.fromJson(e)).toList();
  }
}
