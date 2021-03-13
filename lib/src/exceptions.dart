import 'package:collection/collection.dart' show IterableExtension;
part of postgres.connection;

/// The severity level of a [PostgreSQLException].
///
/// [panic] and [fatal] errors will close the connection.
enum PostgreSQLSeverity {
  /// A [PostgreSQLException] with this severity indicates the throwing connection is now closed.
  panic,

  /// A [PostgreSQLException] with this severity indicates the throwing connection is now closed.
  fatal,

  /// A [PostgreSQLException] with this severity indicates the throwing connection encountered an error when executing a query and the query has failed.
  error,

  /// Currently unsupported.
  warning,

  /// Currently unsupported.
  notice,

  /// Currently unsupported.
  debug,

  /// Currently unsupported.
  info,

  /// Currently unsupported.
  log,

  /// A [PostgreSQLException] with this severity indicates a failed a precondition or other error that doesn't originate from the database.
  unknown
}

/// Exception thrown by [PostgreSQLConnection] instances.
class PostgreSQLException implements Exception {
  PostgreSQLException(this.message,
      {this.severity = PostgreSQLSeverity.error, this.stackTrace}) {
    code = '';
  }

  PostgreSQLException._(List<ErrorField> errorFields, {this.stackTrace}) {
    final finder = (int identifer) => (errorFields.firstWhereOrNull(
        (ErrorField e) => e.identificationToken == identifer));

    severity = ErrorField.severityFromString(
        finder(ErrorField.SeverityIdentifier)!.text);
    code = finder(ErrorField.CodeIdentifier)!.text;
    message = finder(ErrorField.MessageIdentifier)!.text;
    detail = finder(ErrorField.DetailIdentifier)?.text;
    hint = finder(ErrorField.HintIdentifier)?.text;

    internalQuery = finder(ErrorField.InternalQueryIdentifier)?.text;
    trace = finder(ErrorField.WhereIdentifier)?.text;
    schemaName = finder(ErrorField.SchemaIdentifier)?.text;
    tableName = finder(ErrorField.TableIdentifier)?.text;
    columnName = finder(ErrorField.ColumnIdentifier)?.text;
    dataTypeName = finder(ErrorField.DataTypeIdentifier)?.text;
    constraintName = finder(ErrorField.ConstraintIdentifier)?.text;
    fileName = finder(ErrorField.FileIdentifier)?.text;
    routineName = finder(ErrorField.RoutineIdentifier)?.text;

    var i = finder(ErrorField.PositionIdentifier)?.text;
    position = (i != null ? int.parse(i) : null);

    i = finder(ErrorField.InternalPositionIdentifier)?.text;
    internalPosition = (i != null ? int.parse(i) : null);

    i = finder(ErrorField.LineIdentifier)?.text;
    lineNumber = (i != null ? int.parse(i) : null);
  }

  /// The severity of the exception.
  PostgreSQLSeverity? severity;

  /// The PostgreSQL error code.
  ///
  /// May be null if the exception was not generated by the database.
  String? code;

  /// A message indicating the error.
  String? message;

  /// Additional details if provided by the database.
  String? detail;

  /// A hint on how to remedy an error, if provided by the database.
  String? hint;

  /// An index into an executed query string where an error occurred, if by provided by the database.
  int? position;

  /// An index into a query string generated by the database, if provided.
  int? internalPosition;

  String? internalQuery;
  String? trace;
  String? schemaName;
  String? tableName;
  String? columnName;
  String? dataTypeName;
  String? constraintName;
  String? fileName;
  int? lineNumber;
  String? routineName;

  /// A [StackTrace] if available.
  StackTrace? stackTrace;

  @override
  String toString() {
    final buff = StringBuffer('$severity $code: $message ');

    if (detail != null) {
      buff.write('Detail: $detail ');
    }

    if (hint != null) {
      buff.write('Hint: $hint ');
    }

    if (tableName != null) {
      buff.write('Table: $tableName ');
    }

    if (columnName != null) {
      buff.write('Column: $columnName ');
    }

    if (constraintName != null) {
      buff.write('Constraint $constraintName ');
    }

    return buff.toString();
  }
}
