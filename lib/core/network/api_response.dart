class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  const ApiResponse({
    this.data,
    this.message,
    this.success = true,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      success: json['status'] == 'success' || (json['success'] as bool? ?? true),
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, data: $data)';
}
