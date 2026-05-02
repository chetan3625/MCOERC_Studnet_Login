import 'dart:convert';

class SystemLogModel {
  final String? id;
  final DateTime? timestamp;
  final String? level;
  final String? module;
  final String? message;
  final dynamic details;
  final String? admin;
  final String? ip;
  final String? method;
  final String? path;

  SystemLogModel({
    this.id,
    this.timestamp,
    this.level,
    this.module,
    this.message,
    this.details,
    this.admin,
    this.ip,
    this.method,
    this.path,
  });

  factory SystemLogModel.fromJson(Map<String, dynamic> json) {
    return SystemLogModel(
      id: json['_id'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      level: json['level'],
      module: json['module'],
      message: json['message'],
      details: json['details'],
      admin: json['admin'],
      ip: json['ip'],
      method: json['method'],
      path: json['path'],
    );
  }

  String get formattedTime {
    if (timestamp == null) return '';
    return "${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')} • ${timestamp!.day}/${timestamp!.month}";
  }
}
