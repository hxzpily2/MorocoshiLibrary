package net.morocoshi.air.connection 
{
	import flash.events.ErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLVariables;
	import flash.utils.escapeMultiByte;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Login 
	{
		
		private var loader:URLLoader;
		private var completeFunc:Function;
		private var errorFunc:Function;
		
		public function Login() 
		{
		}
		
		public function login(topURL:String, loginURL:String, username:String, password:String, complete:Function = null, error:Function = null):void
		{
			completeFunc = complete;
			errorFunc = error;
			
			//認証情報
			URLRequestDefaults.setLoginCredentialsForHost(topURL, username, password);
			
			//ログインURLにアクセス
			var request:URLRequest = new URLRequest(loginURL);
			request.method = "POST";
			
			//メールアドレスとパスワードをURLエンコードしてリクエストに付加
			var variables:URLVariables = new URLVariables();
			variables.mail = escapeMultiByte(username);
			variables.password = escapeMultiByte(password);
			request.data = variables;
			
			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, login_completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, login_errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, login_errorHandler);
			loader.load(request);
		}
		
		public function close():void
		{
			if (loader)
			{
				removeAllHandlers(loader);
				loader = null;
			}
			completeFunc = null;
			errorFunc = null;
		}
		
		private function removeAllHandlers(loader:URLLoader):void
		{
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, login_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, login_errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, login_errorHandler);	
		}
		
		private function login_completeHandler(e:HTTPStatusEvent):void 
		{
			var func:Function = completeFunc;
			close();
			if (func != null)
			{
				func();
			}
		}
		
		private function login_errorHandler(e:ErrorEvent):void 
		{
			var func:Function = errorFunc;
			close();
			if (func != null)
			{
				func();
			}
		}
		
	}

}