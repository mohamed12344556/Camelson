import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Cache configuration for Dio requests
class CacheConfig {
  static CacheOptions? _cacheOptions;

  /// Initialize cache options with memory store
  static CacheOptions getCacheOptions() {
    _cacheOptions ??= CacheOptions(
      // Cache store using memory (no file/Hive dependency)
      store: MemCacheStore(),

      // Default cache policy - try cache first, then network if expired
      policy: CachePolicy.request,

      // Maximum age of cached data (1 day - reduced for fresher data)
      maxStale: const Duration(days: 1),

      // Cache priority
      priority: CachePriority.high,

      // Optional: Custom cipher for encryption
      cipher: null,

      // Key builder for cache identification
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,

      // Allow POST requests to be cached (useful for some APIs)
      allowPostMethod: false,
    );

    return _cacheOptions!;
  }

  /// Get cache options for requests that should always fetch fresh data
  static CacheOptions getRefreshCacheOptions() {
    return CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.refresh, // Always fetch from network
      maxStale: const Duration(days: 7),
      priority: CachePriority.high,
    );
  }

  /// Get cache options for requests that should use cache or network
  static CacheOptions getCacheStoreOptions() {
    return CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request, // Try cache first, then network
      maxStale: const Duration(days: 30),
      priority: CachePriority.high,
    );
  }

  /// Get cache options for specific duration
  static CacheOptions getCustomCacheOptions({
    required Duration maxAge,
    CachePolicy? policy,
  }) {
    return CacheOptions(
      store: MemCacheStore(),
      policy: policy ?? CachePolicy.forceCache,
      maxStale: maxAge,
      priority: CachePriority.normal,
    );
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    if (_cacheOptions != null) {
      await _cacheOptions!.store?.clean();
    }
  }

  /// Delete specific cache entry by key
  static Future<void> deleteCacheByKey(String key) async {
    if (_cacheOptions != null) {
      await _cacheOptions!.store?.delete(key);
    }
  }

  /// Get cache options for real-time APIs (Community, Questions, SignalR)
  /// These endpoints should NEVER be cached as they need fresh data
  static CacheOptions getNoCacheOptions() {
    return CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.noCache, // Never use cache, always fetch from network
      maxStale: const Duration(seconds: 0),
      priority: CachePriority.high,
    );
  }
}
