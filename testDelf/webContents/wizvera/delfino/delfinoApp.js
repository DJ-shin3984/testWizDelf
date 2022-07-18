(function(GLOBAL){
"strict"

var Delfino = GLOBAL.Delfino;
var DelfinoConfig = GLOBAL.DelfinoConfig;
var SignType = Delfino.SignType;

function adjustSignOptions(signOptions) {
	// set default options
	signOptions.resetCertificate = (signOptions.resetCertificate === undefined || signOptions.resetCertificate === null) ? true : signOptions.resetCertificate;
	signOptions.cacheCertFilter = (signOptions.cacheCertFilter === undefined || signOptions.cacheCertFilter === null) ? false : signOptions.cacheCertFilter;
	signOptions.addNonce = (signOptions.addNonce === undefined || signOptions.addNonce === null) ? false : signOptions.addNonce;
	
	if(signOptions.userCI) {
		signOptions.userCi = signOptions.userCI;
		delete signOptions.userCI;
	}
	
	if(signOptions.userInfo) {
		var userInfo = {
			userName: signOptions.userInfo.UserName,
			userPhone: signOptions.userInfo.UserPhoneNumber,
			userBirthday: signOptions.userInfo.UserBirthday
		};
		
		signOptions.userInfo = userInfo;
	}
	
	return signOptions;
}

function adjustSignData(signData, signOptions, signType) {
	var data = signOptions.data || signData;
	
	if(signType === 'MYDATA') try { data = JSON.parse(data);} catch(e) {};
	
	return data;
}

function sign(request) {
	var signRequest = undefined;
	
	if(typeof request === 'object') {
		signRequest = request;
	} else {
		try { 
			signRequest = JSON.parse(request);
		} catch(e) {
			signRequest = {};
		}
	}
	
	var provider = signRequest.provider;
	var signType = signRequest.signType || SignType.LOGIN;
	var signData = signRequest.signData || '';
	var signOptions = signRequest.signOptions || {};
	
	if(provider === 'pubcert') {
		Delfino.setModule('G4');
	} else {
		Delfino.setModule('G10');

		signOptions.provider = signOptions.provider || provider;
		
		if(provider === 'fincert') {
			signOptions.closeWhenFinCertCanceled = true;
		}
	}
	
	signOptions = adjustSignOptions(signOptions);

	var signFunc = undefined;
	
	if(signType === SignType.LOGIN) {
		signFunc = Delfino.login;
	} else if(signType === SignType.AUTH) {
		signFunc = Delfino.auth;
	} else if(signType === SignType.AUTH2) {
		signFunc = Delfino.auth2;
	} else if(signType === SignType.SIMPLE) {
		signFunc = Delfino.sign;
		
		delete signOptions.dataType;
	} else if(signType === SignType.CONFIRM) {
		signFunc = Delfino.sign;
		
		signOptions.dataType = signOptions.dataType || 'formattedText';
	} else if(signType === "MYDATA") {
		signFunc = Delfino.multiSignForMyData;
	}
	
	signFunc = signFunc.bind(Delfino);
	
	signData = adjustSignData(signData, signOptions, signType);
	
	if(signFunc) {
		signFunc(signData, signOptions, function(result) {
			var VPCGClientApp = GLOBAL.VPCGClientApp || (top && top.VPCGClientApp);

			if(VPCGClientApp && VPCGClientApp.signComplete) {
				VPCGClientApp.signComplete(JSON.stringify(result));
			}
		});
	}
};

		
GLOBAL.DelfinoG10Sign = sign;
	
})(window);