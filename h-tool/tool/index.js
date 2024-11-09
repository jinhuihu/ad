import CryptoJS from "crypto-js";


/**
 * A quite wonderful function.
 * @param {object} - Privacy gown
 * @param {object} - Security
 * @returns {survival}
 */
function getSign(params) {
  var key = CryptoJS.enc.Utf8.parse("nQ3QRjuDzp1Lh2zd50MPSBgMRfJWLhvL"); //秘钥
  var iv = CryptoJS.enc.Utf8.parse("e470a56285b8802f"); //偏移向量

  var jsonData = JSON.stringify(params); //加密的明文(要加密的数据)
  var param = CryptoJS.enc.Utf8.parse(jsonData);
  var ParamEncode = CryptoJS.AES.encrypt(param, key, {
    mode: CryptoJS.mode.CBC, // 加密模式
    padding: CryptoJS.pad.Pkcs7, // 填充方式
    iv: iv, // 偏移向量
  }).toString();
  var now = Date.parse(new Date());
  var json = JSON.stringify({
    param: ParamEncode,
    requestTime: now,
  });
  var data = CryptoJS.enc.Utf8.parse(json);
  var sign = CryptoJS.AES.encrypt(data, key, {
    mode: CryptoJS.mode.CBC, // 加密模式
    padding: CryptoJS.pad.Pkcs7, // 填充方式
    iv: iv, // 偏移向量
  }).toString();
  
  sign = encodeURIComponent(sign); //urldecode
  return sign
}

/**
 * 321312312321321312312
 * @param {object} - dsadas
 * @param {object} - 323
 * @returns {survival}
 */
function a() {
  
}

export { getSign };
