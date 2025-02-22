import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'prices/maybe_error.dart';
import 'prices/price.dart';
import 'prices/proof.dart';
import 'prices/get_locations_parameters.dart';
import 'prices/get_locations_result.dart';
import 'prices/get_parameters_helper.dart';
import 'prices/get_prices_parameters.dart';
import 'prices/get_prices_result.dart';
import 'prices/get_proofs_parameters.dart';
import 'prices/get_proofs_result.dart';
import 'prices/get_users_parameters.dart';
import 'prices/get_users_result.dart';
import 'prices/location.dart';
import 'prices/location_osm_type.dart';
import 'prices/price_product.dart';
import 'prices/proof_type.dart';
import 'prices/session.dart';
import 'utils/http_helper.dart';
import 'utils/open_food_api_configuration.dart';
import 'utils/uri_helper.dart';
import 'utils/uri_reader.dart';

/// Client calls of the Open Prices API.
///
/// cf. https://prices.openfoodfacts.org/api/docs
class OpenPricesAPIClient {
  OpenPricesAPIClient._();

  /// Status when the server is running (cf. [getStatus]).
  static const String statusRunning = 'running';

  /// Subdomain of the Prices API.
  static const String _subdomain = 'prices';

  /// Host of the Elastic Search API.
  static String _getHost(final UriProductHelper uriHelper) =>
      uriHelper.getHost(_subdomain);

  static Future<MaybeError<GetPricesResult>> getPrices(
    final GetPricesParameters parameters, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
    final String? bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices',
      queryParameters: parameters.getQueryParameters(),
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<GetPricesResult>.value(
          GetPricesResult.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<GetPricesResult>.responseError(response);
  }

  static Future<MaybeError<Location>> getOSMLocation({
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/locations/osm/${locationOSMType.offTag}/$locationOSMId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<Location>.value(Location.fromJson(decodedResponse));
      } catch (e) {
        //
      }
    }
    return MaybeError<Location>.responseError(response);
  }

  static Future<MaybeError<GetLocationsResult>> getLocations(
    final GetLocationsParameters parameters, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
    final String? bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/locations',
      queryParameters: parameters.getQueryParameters(),
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<GetLocationsResult>.value(
          GetLocationsResult.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<GetLocationsResult>.responseError(response);
  }

  static Future<MaybeError<Location>> getLocation(
    final int locationId, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/locations/$locationId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<Location>.value(Location.fromJson(decodedResponse));
      } catch (e) {
        //
      }
    }
    return MaybeError<Location>.responseError(response);
  }

  static Future<MaybeError<PriceProduct>> getPriceProductById(
    final int productId, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/products/$productId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<PriceProduct>.value(
          PriceProduct.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<PriceProduct>.responseError(response);
  }

  static Future<MaybeError<PriceProduct>> getPriceProductByCode(
    final String productCode, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/products/code/$productCode',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<PriceProduct>.value(
          PriceProduct.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<PriceProduct>.responseError(response);
  }

  /// Returns the status of the server.
  ///
  /// Expected value: [statusRunning]
  /// cf. https://prices.openfoodfacts.org/api/docs#/default/status_endpoint_api_v1_status_get
  static Future<MaybeError<String>> getStatus({
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/status',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<String>.value(decodedResponse['status']!);
      } catch (e) {
        //
      }
    }
    return MaybeError<String>.responseError(response);
  }

  /// Authentication: provide username/password and get a bearer token in return.
  ///
  /// [username]: Open Food Facts user_id (not email)
  /// [password]: user password (clear text, but HTTPS encrypted)
  /// A token is returned. If the set_cookie parameter is set to 1, the token is also set as a cookie named "session" in the response.
  /// To authenticate, you can either:
  /// - use the Authorization header with the Bearer scheme, e.g.: "Authorization: bearer token"
  /// - use the session cookie, e.g.: "Cookie: session=token"
  static Future<MaybeError<String>> getAuthenticationToken({
    required final String username,
    required final String password,
    final bool setCookie = false,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/auth${setCookie ? '?set_cookie=1' : ''}',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await post(
      uri,
      body: <String, String>{
        'username': username,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<String>.value(decodedResponse['access_token']);
      } catch (e) {
        //
      }
    }
    return MaybeError<String>.responseError(response);
  }

  /// Returns the session details related to this [bearerToken].
  static Future<MaybeError<Session>> getUserSession({
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/session',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> json = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<Session>.value(Session.fromJson(json));
      } catch (e) {
        //
      }
    }
    return MaybeError<Session>.responseError(response);
  }

  /// Deletes a user session.
  ///
  /// Returns true if successful.
  static Future<MaybeError<bool>> deleteUserSession({
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/session',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doDeleteRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      return MaybeError<bool>.value(true);
    }
    return MaybeError<bool>.responseError(response);
  }

  static Future<MaybeError<Price>> createPrice({
    required final Price price,
    required final String bearerToken,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices',
      forcedHost: _getHost(uriHelper),
    );
    final StringBuffer body = StringBuffer();
    body.write('{');
    if (price.productCode != null) {
      body.write('"product_code": "${price.productCode}",');
    }
    if (price.productName != null) {
      body.write('"product_name": "${price.productName}",');
    }
    if (price.categoryTag != null) {
      body.write('"category_tag": "${price.categoryTag}",');
    }
    if (price.labelsTags != null) {
      body.write('"labels_tags": "${price.labelsTags}",');
    }
    if (price.originsTags != null) {
      body.write('"origins_tags": "${price.originsTags}",');
    }
    if (price.proofId != null) {
      body.write('"proof_id": ${price.proofId},');
    }
    if (price.pricePer != null) {
      body.write('"price_per": "${price.pricePer!.offTag}",');
    }
    if (price.priceWithoutDiscount != null) {
      body.write('"price_without_discount": ${price.priceWithoutDiscount},');
    }
    if (price.priceIsDiscounted != null) {
      body.write('"price_is_discounted": ${price.priceIsDiscounted},');
    }
    body.write('"price": ${price.price},');
    body.write('"currency": "${price.currency.name}",');
    body.write('"location_osm_id": ${price.locationOSMId},');
    body.write('"location_osm_type": "${price.locationOSMType.offTag}",');
    body.write('"date": "${GetParametersHelper.formatDate(price.date)}"');
    body.write('}');
    final Response response = await HttpHelper().doPostJsonRequest(
      uri,
      body.toString(),
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 201) {
      try {
        final Map<String, dynamic> json = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<Price>.value(Price.fromJson(json));
      } catch (e) {
        //
      }
    }
    return MaybeError<Price>.responseError(response);
  }

  /// Deletes a price.
  /// A user can delete only owned prices.
  /// Returns true if successful.
  static Future<MaybeError<bool>> deletePrice({
    required final int priceId,
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices/$priceId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doDeleteRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 204) {
      return MaybeError<bool>.value(true);
    }
    return MaybeError<bool>.responseError(response);
  }

  /// Get user proofs.
  static Future<MaybeError<GetProofsResult>> getProofs(
    final GetProofsParameters parameters, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/proofs',
      queryParameters: parameters.getQueryParameters(),
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<GetProofsResult>.value(
          GetProofsResult.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<GetProofsResult>.responseError(response);
  }

  static Future<MaybeError<Proof>> uploadProof({
    required final ProofType proofType,
    required final Uri imageUri,
    required final MediaType mediaType,
    required final String bearerToken,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/proofs/upload',
      forcedHost: _getHost(uriHelper),
    );

    final http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'bearer $bearerToken',
      'Content-Type': 'multipart/form-data',
    });
    request.fields.addAll(
      <String, String>{
        'type': proofType.offTag,
      },
    );
    final List<int> fileBytes = await UriReader.instance!.readAsBytes(imageUri);
    final String filename = basename(imageUri.toString());
    final http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
      contentType: mediaType,
    );
    request.files.add(multipartFile);

    final StreamedResponse response = await request.send();

    final String responseBody = await HttpHelper().extractResponseAsString(
      response,
    );
    if (response.statusCode == 201) {
      try {
        final Map<String, dynamic> json = HttpHelper().jsonDecode(responseBody);
        return MaybeError<Proof>.value(Proof.fromJson(json));
      } catch (e) {
        //
      }
    }
    return MaybeError<Proof>.error(
      error: responseBody,
      statusCode: response.statusCode,
    );
  }

  /// Get user proof by id.
  static Future<MaybeError<Proof>> getProof(
    final int proofId, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/proofs/$proofId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<Proof>.value(Proof.fromJson(decodedResponse));
      } catch (e) {
        //
      }
    }
    return MaybeError<Proof>.responseError(response);
  }

  /// Deletes a proof.
  /// A user can delete only owned proofs. Can delete only proofs that are not associated with prices. A moderator can delete not owned proofs.
  /// Returns true if successful.
  static Future<MaybeError<bool>> deleteProof({
    required final int proofId,
    final UriProductHelper uriHelper = uriHelperFoodProd,
    required final String bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/proofs/$proofId',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doDeleteRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 204) {
      return MaybeError<bool>.value(true);
    }
    return MaybeError<bool>.responseError(response);
  }

  static Future<MaybeError<GetUsersResult>> getUsers(
    final GetUsersParameters parameters, {
    final UriProductHelper uriHelper = uriHelperFoodProd,
    final String? bearerToken,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/users',
      queryParameters: parameters.getQueryParameters(),
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
      bearerToken: bearerToken,
    );
    if (response.statusCode == 200) {
      try {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<GetUsersResult>.value(
          GetUsersResult.fromJson(decodedResponse),
        );
      } catch (e) {
        //
      }
    }
    return MaybeError<GetUsersResult>.responseError(response);
  }
}
