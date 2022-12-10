"""This is a sample Hello World API implemented using Google Cloud
Endpoints."""

# [START endpoints_echo_api_imports]
import endpoints
from endpoints import message_types
from endpoints import messages
from endpoints import remote
# [END endpoints_echo_api_imports]


# [START endpoints_echo_api_messages]
class EchoRequest(messages.Message):
    message = messages.StringField(1)


class EchoResponse(messages.Message):
    """A proto Message that contains a simple string field."""
    message = messages.StringField(1)


ECHO_RESOURCE = endpoints.ResourceContainer(
    EchoRequest,
    n=messages.IntegerField(2, default=1))
# [END endpoints_echo_api_messages]


# [START endpoints_echo_api_class]
@endpoints.api(name='echo', version='v1')
class EchoApi(remote.Service):

    # [START endpoints_echo_api_method]
    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        ECHO_RESOURCE,
        # This method returns an Echo message.
        EchoResponse,
        path='echo',
        http_method='POST',
        name='echo')
    def echo(self, request):
        output_message = ' '.join([request.message] * request.n)
        return EchoResponse(message=output_message)
    # [END endpoints_echo_api_method]

    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        ECHO_RESOURCE,
        # This method returns an Echo message.
        EchoResponse,
        path='echo/{n}',
        http_method='POST',
        name='echo_path_parameter')
    def echo_path_parameter(self, request):
        output_message = ' '.join([request.message] * request.n)
        return EchoResponse(message=output_message)

    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        message_types.VoidMessage,
        # This method returns an Echo message.
        EchoResponse,
        path='echo/getApiKey',
        http_method='GET',
        name='echo_api_key',
        api_key_required=True)
    def echo_api_key(self, request):
        key, key_type = request.get_unrecognized_field_info('key')
        return EchoResponse(message=key)

    @endpoints.method(
        # This method takes an empty request body.
        message_types.VoidMessage,
        # This method returns an Echo message.
        EchoResponse,
        path='echo/email',
        http_method='GET',
        # Require auth tokens to have the following scopes to access this API.
        scopes=[endpoints.EMAIL_SCOPE],
        # OAuth2 audiences allowed in incoming tokens.
        audiences=['your-oauth-client-id.com'],
        allowed_client_ids=['your-oauth-client-id.com'])
    def get_user_email(self, request):
        user = endpoints.get_current_user()
        # If there's no user defined, the request was unauthenticated, so we
        # raise 401 Unauthorized.
        if not user:
            raise endpoints.UnauthorizedException
        return EchoResponse(message=user.email())
# [END endpoints_echo_api_class]


# [START endpoints_api_server]
api = endpoints.api_server([EchoApi])
# [END endpoints_api_server]
