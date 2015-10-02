package net.morocoshi.common.loaders.tfp 
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import net.morocoshi.common.encoders.Base64;
	/**
	 * Basic認証関係の処理
	 * 
	 * @author tencho
	 */
	public class BasicAuthenticationManager 
	{
		
		/**
		 * ユーザー名/パスワードでBasic認証用のURLRequestを生成する
		 * @param	user
		 * @param	pass
		 * @return
		 */
		static public function createRequest(user:String, pass:String):URLRequest
		{
			var b64:String = Base64.encode(user + ":" + pass);
			var header:URLRequestHeader = new URLRequestHeader("Authorization", "Basic " + b64);
			var req:URLRequest = new URLRequest();
			req.requestHeaders.push(header);
			req.method = URLRequestMethod.POST;
			req.data = { };
			return req;
		}
		
	}

}