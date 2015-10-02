package net.morocoshi.common.loaders.tfp 
{
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import net.morocoshi.common.loaders.tfp.events.ITFPFileErrorEvent;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.common.loaders.tfp.events.TFPEventUtil;
	
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	[Event(name = "loadError", type = "net.morocoshi.loaders.tfp.events.TFPErrorEvent")]
	[Event(name = "instantiationError", type = "net.morocoshi.loaders.tfp.events.TFPErrorEvent")]
	
	/**
	 * アセットデータの一括読み込みクラス。
	 * 必要に応じて結合されたTFPデータからのパースと、外部アセットの個別読み込みとを切り替えます。
	 * 
	 * @author tencho
	 */
	public class TFPLoader extends EventDispatcher
	{
		static private var _singleDirectories:Vector.<String> = new Vector.<String>;
		static private var _directories:Vector.<String> = new Vector.<String>;
		static private var _regExpDirectories:Object = { };
		static private var regExpCount:int = -1;
		
		/**TFPLoaderがロードした全アセットのキャッシュ。キーはファイルパス。cacheEnabled=true時に読み込んだデータが全てここに保存される*/
		static public var assetCache:Object = { };
		/**各ファイルパスごとの最後に読み込んだ時のハッシュ*/
		static private var lastCacheHash:Object = { };
		/**各アセットの拡張子の情報*/
		static public var extension:TFPExtention = new TFPExtention();
		
		/**同時ロードの限界数。*/
		public var multiLoadLimit:int = 4;
		/**読み込んだデータをstaticなキャッシュに保存するかどうか*/
		public var cacheEnabled:Boolean = true;
		/**コンストラクタで渡したTFPHolder。ロードされた各種アセットはここに格納されます。*/
		public var holder:TFPHolder;
		
		/**キャッシュ対策用にパスに追加する文字列（？は除く）*/
		private var _cacheHash:String = "";
		/**インスタンス変換用一時ファイル（読み込みが完了するとnullになる）*/
		private var library:TFPLibrary;
		/**ロードするファイルの個数*/
		private var totalSize:Number;
		/**progressイベント発行時の時間計測用*/
		private var time:int;
		/**ロード待ちのファイルリスト*/
		private var stockFileList:Vector.<FileData>;
		/**ロード中のファイルリスト*/
		private var loadingFileList:Vector.<FileData>;
		/**ロードが完了した個数*/
		private var numComplete:int;
		
		/**ファイルロード時に使うURLRequest*/
		public var urlRequest:URLRequest;
		private var URLLoaderClass:Class;
		private var _isLoading:Boolean;
		
		private var errorEventList:Vector.<ITFPFileErrorEvent>;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function TFPLoader(holder:TFPHolder)
		{
			time = 0;
			numComplete = 0;
			urlRequest = new URLRequest();
			URLLoaderClass = URLLoader;
			loadingFileList = new Vector.<FileData>;
			stockFileList = new Vector.<FileData>;
			errorEventList = new Vector.<ITFPFileErrorEvent>;
			_isLoading = false;
			if (holder == null)
			{
				throw new Error("[TFPLoader]コンストラクタ引数のTFPHolderがnullです。");
			}
			this.holder = holder;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * TFPの拡張子を設定する
		 * @param	value
		 */
		static public function setTFPExtension(value:String):void
		{
			extension.tfp = value;
		}
		
		/**
		 * TFPの拡張子を取得する
		 * @return
		 */
		static public function getTFPExtension():String
		{
			return extension.tfp;
		}
		
		/**
		 * TFPデータを自動展開するディレクトリパスのリスト
		 */
		static public function get directories():Vector.<String> 
		{
			return _directories;
		}
		
		/**
		 * TFPデータを展開する個別のディレクトリパスのリスト
		 */
		static public function get singleDirectories():Vector.<String> 
		{
			return _singleDirectories;
		}
		
		/**
		 * ロード中かどうか
		 */
		public function get isLoading():Boolean 
		{
			return _isLoading;
		}
		
		public function get cacheHash():String 
		{
			return _cacheHash;
		}
		
		public function set cacheHash(value:String):void 
		{
			_cacheHash = value;
		}
		
		static public function get regExpDirectories():Object 
		{
			return _regExpDirectories;
		}
		
		//--------------------------------------------------------------------------
		//
		//  TFPディレクトリの登録、削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * TFPデータを展開する個別のディレクトリパスを追加します。
		 * 指定したディレクトリ自体がTFP自動展開の対象になります。
		 * @param	path
		 */
		static public function addSingleTFPDirectory(path:String):void 
		{
			path = correctTFPDirectory(fixFilePath(path));
			if (!path) throw new Error("[TFPLoader]無効なパスは登録できません。");
			//二重登録防止
			if (_singleDirectories.indexOf(path) != -1) return;
			
			_singleDirectories.push(path);
		}
		
		/**
		 * TFPデータを自動展開するディレクトリパスを追加します。
		 * 指定したディレクトリ直下の全サブフォルダがTFP自動展開の対象になります。
		 * @param	path
		 */
		static public function addTFPDirectory(path:String):void
		{
			path = correctTFPDirectory(fixFilePath(path));
			//二重登録防止
			if (_directories.indexOf(path) != -1) return;
			
			_directories.push(path);
		}
		
		/**
		 * TFPを展開するディレクトリを正規表現で登録し、削除用ID(0以上)を返す。二重登録チェックで弾かれた場合は-1.
		 * @param	pattern
		 * @param	options
		 */
		static public function addRegExpTFPDirectory(pattern:String, options:String):int
		{
			pattern = correctTFPDirectory(pattern);
			var result:RegExp = new RegExp(pattern, options);
			
			//二重登録防止
			var regKey:String = toRegKey(result);
			for each(var reg:RegExp in _regExpDirectories)
			{
				if (regKey == toRegKey(reg)) return -1;
			}
			
			regExpCount++;
			_regExpDirectories[regExpCount] = result;
			
			return regExpCount;
		}
		
		/**
		 * RegExpを文字列化
		 * @param	reg
		 * @return
		 */
		static private function toRegKey(reg:RegExp):String
		{
			return [reg.source, reg.multiline, reg.ignoreCase, reg.global, reg.extended, reg.dotall].join("\t");
		}
		
		/**
		 * TFPデータを展開する個別のディレクトリパスを削除。
		 * @param	path
		 */
		static public function removeSingleTFPDirectory(path:String):void
		{
			path = correctTFPDirectory(fixFilePath(path));
			
			var index:int = _singleDirectories.indexOf(path);
			if (index >= 0)
			{
				_singleDirectories.splice(index, 1);
			}
		}
		
		/**
		 * TFPデータを自動展開するディレクトリパスを削除。
		 * @param	path
		 */
		static public function removeTFPDirectory(path:String):void
		{
			path = correctTFPDirectory(fixFilePath(path));
			
			var index:int = _directories.indexOf(path);
			if (index >= 0)
			{
				_directories.splice(index, 1);
			}
			
		}
		
		/**
		 * 正規表現ディレクトリを削除。
		 * @param	pattern
		 * @param	options
		 */
		static public function removeRegExpTFPDirectory(id:int):void
		{
			delete _regExpDirectories[id];
		}
		
		/**
		 * 全ての、TFPデータを自動展開するディレクトリパスを削除。（通常、シングル、正規表現全て）
		 */
		static public function removeAllTFPDirectory():void
		{
			_directories.length = 0;
			_singleDirectories.length = 0;
			_regExpDirectories = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  キャッシュ管理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * TFPLoaderがキャッシュしている全アセットをクリアします。
		 * アセットデータへの参照が切られるだけでデータの中身は弄りません。
		 */
		static public function clearCache():void
		{
			assetCache = { };
		}
		
		/**
		 * TFPLoaderがキャッシュしている全アセットデータを可能な限り破棄します。
		 * アセットデータをどこかで使っている場合は注意してください。
		 */
		static public function disposeCache():void
		{
			for (var key:String in assetCache)
			{
				var asset:* = assetCache[key];
				if (asset == null) continue;
				if (asset is BitmapData) BitmapData(asset).dispose();
				if (asset is ByteArray) ByteArray(asset).clear();
				if (asset is XML) System.disposeXML(asset);
			}
			assetCache = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  Basic認証
		//
		//--------------------------------------------------------------------------
		
		/**
		 * load()時にユーザー名/パスワードでBasic認証させる為の設定を行う。
		 * @param	user
		 * @param	pass
		 */
		public function setBasicAuthentication(user:String, pass:String):void
		{
			urlRequest = BasicAuthenticationManager.createRequest(user, pass);
		}
		
		//--------------------------------------------------------------------------
		//
		//  使用クラスの設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ロード時に使用するURLLoaderクラスを指定する。
		 * @param	urlLoader	URLLoaderを継承したクラス
		 */
		public function setLoaderClass(urlLoader:Class):void
		{
			if (!checkExtendsClass(urlLoader, URLLoader))
			{
				throw new Error("[TFPLoader]urlLoaderにはURLLoader型のクラスを指定してください。");
				return;
			}
			URLLoaderClass = urlLoader;
		}
		
		/**
		 * 指定のクラスが特定のクラスを継承しているかチェックする。
		 * @param	target	調べるクラス
		 * @param	extend	これを継承しているかチェック
		 * @return
		 */
		static public function checkExtendsClass(target:Class, extend:Class):Boolean 
		{
			var className:String = getQualifiedClassName(extend);
			var factory:XML = describeType(target).factory[0];
			if (factory.@type == className) return true;
			for each(var type:String in factory.extendsClass.@type)
			{
				if (type == className) return true;
			}
			return false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  データ読み込み開始
		//
		//--------------------------------------------------------------------------
		
		/**
		 * アセットパスの配列で一括読み込みする。
		 * @param	pathList
		 */
		public function load(pathList:Vector.<String>):void
		{
			if (_isLoading)
			{
				throw new Error("[TFPLoader]読み込みが未完了の状態でload()が実行されました。");
				return;
			}
			
			_isLoading = true;
			stockFileList.length = 0;
			loadingFileList.length = 0;
			errorEventList.length = 0;
			numComplete = 0;
			
			//キーにファイルパスを持つ
			var fileRequest:Object = { };
			
			var i:int;
			var n:int;
			
			n = pathList.length;
			for (i = 0; i < n; i++)
			{
				//ロードファイルパス
				var path:String = fixFilePath(pathList[i]);
				
				//すでにキャッシュにある場合は処理をスキップ(ハッシュもチェックする)
				if (assetCache[path] && lastCacheHash[path] === _cacheHash)
				{
					//キャッシュからholderへデータの参照をコピー
					holder.asset[path] = assetCache[path];
					continue;
				}
				lastCacheHash[path] = _cacheHash;
				
				var match:Boolean = matchDirectories(fileRequest, path);
				
				//ロードするファイルがどのTFPフォルダとも一致しない場合
				if (match == false)
				{
					//読み込みリストに元ファイルパスを登録
					registerLoadPath(fileRequest, path, path);
				}
			}
			
			//読み込むファイルをFileDataインスタンスにしてリストに入れておく
			for (var key:String in fileRequest)
			{
				var type:String = extension.getTypeByFileName(key);
				//pathList:TFP内の複数ファイルの配列（読み込もうとしたファイル分ある）
				var pathArray:Array = fileRequest[key];
				var file:FileData = new FileData(key, type, pathArray);
				file.cacheHash = cacheHash;
				file.addEventListener(ProgressEvent.PROGRESS, file_progressHandler);
				file.addEventListener(Event.COMPLETE, file_completeHandler);
				file.addEventListener(IOErrorEvent.IO_ERROR, file_errorHandler);
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, file_errorHandler);
				stockFileList.push(file);
			}
			
			totalSize = stockFileList.length;
			library = new TFPLibrary();
			library.files = new Vector.<TFPFile>;
			
			//ロード開始（同時に複数ロード）
			n = Math.min(stockFileList.length, multiLoadLimit);
			if (n == 0)
			{
				//読み込むファイルが無い場合は完了させる
				convertAllInstance();
				return;
			}
			for (i = 0; i < n; i++) 
			{
				loadStockFile();
			}
		}
		
		/**
		 * 指定のパスが各種TFPフォルダと一致するかどうかをチェックし、TFPに内包されるファイルだったらリストへ追加する
		 * @param	request
		 * @param	path
		 * @return
		 */
		private function matchDirectories(request:Object, path:String):Boolean 
		{
			//登録済みTFP個別フォルダリストをチェック
			if (matchSingleDirectories(request, path))
			{
				return true;
			}
			//登録済みTFPフォルダリストをチェック
			else if (matchTFPDirectories(request, path))
			{
				return true;
			}
			//登録済み正規表現リストをチェック
			else if (matchRegExpDirectories(request, path))
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 登録済みTFP個別フォルダリストをチェック
		 * @param	tfp
		 * @param	path
		 */
		private function matchSingleDirectories(data:Object, path:String):Boolean 
		{
			var match:Boolean = false;
			var n:int = _singleDirectories.length;
			for (var i:int = 0; i < n; i++)
			{
				var dir:String = _singleDirectories[i];
				//ロードファイルパスがTFPフォルダと一致する場合
				if (path.indexOf(dir) == 0)
				{
					match = true;
					var len:int = dir.length - 1;
					if (dir.charAt(len) == "/")
					{
						dir = dir.substr(0, len);
					}
					//読み込みリストにTFPファイルパスを登録
					var tfpPath:String = dir + "." + extension.tfp;
					registerLoadPath(data, tfpPath, path);
				}
			}
			return match;
		}
		
		/**
		 * 登録済みTFPフォルダリストをチェック
		 * @param	data
		 * @param	path
		 * @return
		 */
		private function matchTFPDirectories(data:Object, path:String):Boolean 
		{
			var match:Boolean = false;
			var n:int = _directories.length;
			for (var i:int = 0; i < n; i++)
			{
				//登録済みTFPフォルダ
				var dir:String = _directories[i];
				//ロードファイルパスがTFPフォルダと一致する場合
				if (path.indexOf(dir) == 0)
				{
					//元ファイルパスからTFPディレクトリを削り、最初のフォルダをTFPファイル名とする
					var localPath:String = path.substr(dir.length);
					//TFPを削った残りの文字列にディレクトリ文字が見つからない場合はフォルダが特定できないのでスキップ
					if (localPath.indexOf("/") == -1) continue;
					
					match = true;
					var tfpName:String = localPath.split("/").shift();
					var tfpPath:String = dir + tfpName + "." + extension.tfp;
					//読み込みリストにTFPファイルパスを登録
					registerLoadPath(data, tfpPath, path);
				}
			}
			return match;
		}
		
		/**
		 * 登録済み正規表現リストをチェック
		 * @param	data
		 * @param	path
		 * @return
		 */
		private function matchRegExpDirectories(data:Object, path:String):Boolean 
		{
			var match:Boolean = false;
			for each(var reg:RegExp in _regExpDirectories)
			{
				if (reg.test(path) && reg.lastIndex == 0)
				{
					var dir:String = reg.exec(path)[0];
					//部分一致したキーワードが文字列の先頭になかった場合はスキップ
					if (path.indexOf(dir) != 0)
					{
						continue;
					}
					//元ファイルパスからTFPディレクトリを削り、最初のフォルダをTFPファイル名とする
					var localPath:String = path.substr(dir.length);
					//TFPを削った残りの文字列にディレクトリ文字が見つからない場合はフォルダが特定できないのでスキップ
					if (localPath.indexOf("/") == -1) continue;
					
					match = true;
					var tfpName:String = localPath.split("/").shift();
					var tfpPath:String = dir + tfpName + "." + extension.tfp;
					//読み込みリストにTFPファイルパスを登録
					registerLoadPath(data, tfpPath, path);
				}
			}
			return match;
		}
		
		/**
		 * data[tfpPath]にassetPathをpushする。まだ配列が生成されていなければ作る。
		 * @param	data
		 * @param	tfpPath
		 * @param	assetPath
		 */
		private function registerLoadPath(data:Object, tfpPath:String, assetPath:String):void 
		{
			if (!data[tfpPath])
			{
				data[tfpPath] = [];
			}
			data[tfpPath].push(assetPath);
		}
		
		/**
		 * TFPデータ（ByteArray）から素材をロードする。
		 * @param	tfp
		 */
		public function loadFromByteArray(tfp:ByteArray):void
		{
			_isLoading = true;
			var parser:TFPParser = new TFPParser();
			parser.addEventListener(IOErrorEvent.IO_ERROR, parser_errorHandler);
			parser.addEventListener(SecurityErrorEvent.SECURITY_ERROR, parser_errorHandler);
			parser.addEventListener(Event.COMPLETE, parser_completeHandler);
			parser.parse(tfp, false);
		}
		
		private function parser_errorHandler(e:ErrorEvent):void 
		{
			removeAllEvents(e.currentTarget as EventDispatcher);
			
			var parser:TFPParser = e.currentTarget as TFPParser;
			parser.dispose();
			var event:TFPErrorEvent = new TFPErrorEvent(TFPErrorEvent.LOAD_ERROR, false, false, "TFPデータのパースに失敗しました。", 0);
			event.attachErrorEvent(TFPEventUtil.toTFPFileErrorEvent(e));
			
			dispatchEvent(event);
		}
		
		private function parser_completeHandler(e:Event):void 
		{
			removeAllEvents(e.currentTarget as EventDispatcher);
			
			var parser:TFPParser = e.currentTarget as TFPParser;
			library = new TFPLibrary();
			library.files = parser.files.concat();
			parser.dispose();
			
			convertAllInstance();
		}
		
		/**
		 * 各種イベントリスナーを削除する。
		 * @param	completeHandler
		 * @param	ioErrorHandler
		 * @param	securityErrorHandler
		 */
		public function deleteEventListener(completeHandler:Function = null, ioErrorHandler:Function = null, securityErrorHandler:Function = null):void 
		{
			if (ioErrorHandler != null) removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			if (securityErrorHandler != null) removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			if (completeHandler != null) removeEventListener(Event.COMPLETE, completeHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  読み込み処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ストックに貯めてあるファイルを順に読み込んでいく
		 */
		private function loadStockFile():void 
		{
			//全て読み込めたら完了処理へ
			if (numComplete >= totalSize)
			{
				convertAllInstance();
				return;
			}
			
			if (stockFileList.length == 0) return;
			
			var file:FileData = stockFileList.pop();
			//既にロード済みだったらスキップ
			if (assetCache[file.path] && lastCacheHash[file.path] === file.cacheHash)
			{
				//キャッシュからholderへデータの参照をコピー
				holder.asset[file.path] = assetCache[file.path];
				numComplete++;
				loadStockFile();
			}
			else
			{
				file.load(urlRequest, URLLoaderClass);
			}
		}
		
		/**
		 * 読み込み失敗
		 * @param	e
		 */
		private function file_errorHandler(e:ErrorEvent):void 
		{
			var file:FileData = e.currentTarget as FileData;
			removeAllFileEvents(file);
			errorEventList.push(e);
			
			numComplete++;
			loadStockFile();
		}
		
		private function file_completeHandler(e:Event):void 
		{
			var file:FileData = e.currentTarget as FileData;
			//ハッシュの更新
			file.setLastCacheHash(lastCacheHash);
			removeAllFileEvents(file);
			library.files = library.files.concat(file.fileList);
			numComplete++;
			loadStockFile();
		}
		
		private function file_progressHandler(e:ProgressEvent):void 
		{
			var t:int = getTimer();
			if (t - time > 20)
			{
				var loaded:Number = numComplete;
				for each (var item:FileData in loadingFileList) 
				{
					loaded += item.loadedRate;
				}
				notifyProgress(loaded / totalSize);
				time = t;
			}
		}
		
		private function removeAllFileEvents(file:FileData):void 
		{
			file.removeEventListener(ProgressEvent.PROGRESS, file_progressHandler);
			file.removeEventListener(Event.COMPLETE, file_completeHandler);
			file.removeEventListener(IOErrorEvent.IO_ERROR, file_errorHandler);
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, file_errorHandler);	
		}
		
		/**
		 * 全FileData読み込み完了
		 */
		private function convertAllInstance():void 
		{
			//非TFPデータはまとめてインスタンス化する
			var loader:InstanceLoader = new InstanceLoader();
			loader.addEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instance_errorHandler);
			loader.addEventListener(Event.COMPLETE, instance_completeHandler);
			loader.load(library);
		}
		
		/**
		 * インスタンス化エラー発生時
		 * @param	e
		 */
		private function instance_errorHandler(e:TFPErrorEvent):void 
		{
			removeAllEvents(e.currentTarget as EventDispatcher);
			_isLoading = false;
			
			dispatchEvent(e);
		}
		
		/**
		 * 全ての処理が完了した
		 * @param	e
		 */
		private function instance_completeHandler(e:Event):void 
		{
			removeAllEvents(e.currentTarget as EventDispatcher);
			
			for each (var file:TFPFile in library.files)
			{
				var key:String = fixFilePath(file.path);
				holder.asset[key] = file.asset;
				//キャッシュが有効ならstaticな場所にキャッシュを貯める
				if (cacheEnabled)
				{
					assetCache[key] = file.asset;
				}
				file.asset = null;
			}
			
			library = null;
			_isLoading = false;
			
			//エラーが1つでもあったらエラーイベント
			var numError:int = errorEventList.length;
			if (numError)
			{
				var errorMessage:String = "読み込みに失敗したファイルがあります。(" + numError + ")" + errorEventList.join(", ");
				var errorEvent:TFPErrorEvent = new TFPErrorEvent(TFPErrorEvent.LOAD_ERROR, false, false, errorMessage, 0);
				for (var i:int = 0; i < numError; i++) 
				{
					errorEvent.attachErrorEvent(errorEventList[i]);
				}
				dispatchEvent(errorEvent);
				return;
			}
			
			//エラーがなければ完了イベント
			notifyComplete();
		}
		
		//--------------------------------------------------------------------------
		//
		//  デバッグ関連
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パスのリストを渡してTFP化の対象になっているか解析する
		 * @param	pathList
		 * @return
		 */
		public function analysis(pathList:Vector.<String>):TFPAnalysisResult
		{
			var result:TFPAnalysisResult = new TFPAnalysisResult();
			var n:int = pathList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var path:String = pathList[i];
				var match:Boolean = matchDirectories(result.tfpRequest, path);
				if (match)
				{
					result.packedFiles.push(path);
				}
				else
				{
					result.rawFiles.push(path);
				}
			}
			
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  通知
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 読み込み状況を通知する
		 * @param	force	
		 */
		private function notifyProgress(rate:Number):void 
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, rate, 1));
		}
		
		/**
		 * 完了イベントを通知する。
		 */
		private function notifyComplete():void
		{
			notifyProgress(1);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * イベントリスナー一括削除
		 * @param	target
		 */
		private function removeAllEvents(target:EventDispatcher):void
		{
			target.removeEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instance_errorHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, parser_errorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, parser_errorHandler);
			target.removeEventListener(Event.COMPLETE, parser_completeHandler);
			target.removeEventListener(Event.COMPLETE, instance_completeHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  その他
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ￥を/に変換する
		 * @param	path
		 * @return
		 */
		static public function fixFilePath(path:String):String
		{
			if (!path) return path;
			if (path.indexOf("\\") >= 0)
			{
				path = path.split("\\").join("/");
			}
			return path;
		}
		
		/**
		 * TFPフォルダ登録時に正しいパスに変換する。
		 * @param	path
		 * @return
		 */
		static private function correctTFPDirectory(path:String):String
		{
			//無ければ最後にスラッシュを追加する
			if (path.charAt(path.length - 1) != "/") path += "/";
			//スラッシュだけだったら空文字化
			if (path == "/") path = "";
			
			return path;
		}
		
	}
	
}