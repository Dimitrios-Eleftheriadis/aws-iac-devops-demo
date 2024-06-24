module.exports = (config) => {
    console.log('Middy http responses loading...');

    return({
        onError: (handler, next) =>{
            console.log('Middy onError. Middy is handling the error');

            const error = handler.error || {};

            if((!error.statusCode) || (!error.message)){
                console.log('Unexpected error occured!');
            }

            console.log('Error raised is: ', JSON.stringify(error, null, 4));

            const errorBody = {
                message: error.message || 'Unknown error',
                errorCode: error.code || 'Unknown error'
            };

            if(error.info){
                errorBody['info'] = error.info;
            }

            handler.response = {
                statusCode: errorBody.statusCode || 500,
                header: {
                    'Access-Control-Allow-Origin': "*",
                    'Access-Control-Allow-Credentials': "true"
                },
                body: JSON.stringify(errorBody)
            };

            return;
        },

        after: (hanlder, next) => {
            console.log('Middy after')
        }

    });
}