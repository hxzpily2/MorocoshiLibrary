package net.morocoshi.air.files
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	
	/**
	 * AIRでローカルに保存するデータを管理するクラス。
	 * このクラスを継承した新しいクラスに定義したpublicな変数が自動保存に使われます。
	 * 
	 * @author	tencho
	 */
	public class UserData
	{
		/**自動保存直前に実行される*/
		public var onBeforeSave:Function = null;
		
		private var _file:File;
		private var _window:NativeWindow;
		private var _saveWindowSize:Boolean = true;
		private var _saveWindowPosition:Boolean = true;
		private var _windowRect:Rectangle = new Rectangle();
		private var _windowMaximized:Boolean = false;
		private var _compress:Boolean;
		
		/**
		 * コンストラクタ
		 * @param	fileName　ローカルに保存するファイルの拡張子を含めた名前。以前はデフォルトで「userdata」だった
		 * @param	compress 保存データを圧縮するかどうか
		 */
		public function UserData(fileName:String = "userdata.dat", compress:Boolean = true)
		{
			_file = File.applicationStorageDirectory.resolvePath(fileName);
			_compress = compress;
		}
		
		/**
		 * 保存データを圧縮するかどうか
		 */
		public function get compress():Boolean 
		{
			return _compress;
		}
		
		public function set compress(value:Boolean):void 
		{
			_compress = value;
		}
		
		/**
		 * ローカルに保存するファイルの場所を扱う為のFileオブジェクト。
		 */
		public function get file():File 
		{
			return _file;
		}
		
		public function set file(value:File):void 
		{
			_file = value;
		}
		
		/**
		 * ウィンドウを閉じた時に自動で保存する
		 * @param	enable	自動保存を有効にするか
		 * @param	win	対象のウィンドウ
		 * @param	withWindowRect	ウィンドウ位置も保存するか
		 */
		public function init(window:NativeWindow, autoSave:Boolean = true, saveWindowPosition:Boolean = true, saveWindowSize:Boolean = true):void
		{
			_window = window;
			_saveWindowPosition = saveWindowPosition;
			_saveWindowSize = saveWindowSize;
			if (autoSave)
			{
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, window_closingHandler);
				_window.addEventListener(Event.CLOSING, window_closingHandler);
				_window.addEventListener(NativeWindowBoundsEvent.RESIZE, window_resizeHandler);
				_window.addEventListener(NativeWindowBoundsEvent.MOVE, window_resizeHandler);
				_window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, window_resizeHandler);
			}
			else
			{
				NativeApplication.nativeApplication.removeEventListener(Event.EXITING, window_closingHandler);
				_window.removeEventListener(Event.CLOSING, window_closingHandler);
				_window.removeEventListener(NativeWindowBoundsEvent.RESIZE, window_resizeHandler);
				_window.removeEventListener(NativeWindowBoundsEvent.MOVE, window_resizeHandler);
				_window.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, window_resizeHandler);
			}
		}
		
		/**
		 * 保存されたデータを読み込む
		 * @param	win	保存しておいたウィンドウ位置を反映させる
		 * @return
		 */
		public function load():Boolean
		{
			var amf:* = LocalFile.readObject(_file, true);
			if (amf == null) return false;
			
			if (amf.value)
			{
				for (var k:String in amf.value)
				{
					try
					{
						this[k] = amf.value[k];
					}
					catch (e:Error) 
					{
					}
				}
			}
			
			if (_window)
			{
				if (_saveWindowPosition)
				{
					_window.x =	_windowRect.x = amf.window.x;
					_window.y =	_windowRect.y = amf.window.y;
				}
				if (_saveWindowSize)
				{
					_window.width =	_windowRect.width = amf.window.width;
					_window.height = _windowRect.height = amf.window.height;
					_windowMaximized = amf.window.maximized;
					if (_windowMaximized)
					{
						_window.maximize();
					}
				}
			}
			
			return true;
		}
		
		/**
		 * ウィンドウリサイズ/移動時
		 * @param	e
		 */
		private function window_resizeHandler(e:Event = null):void
		{
			_windowMaximized = (_window.displayState == NativeWindowDisplayState.MAXIMIZED);
			
			if (_windowMaximized || _window.bounds == null || _windowRect.equals(_window.bounds)) return;
			
			if (_saveWindowPosition)
			{
				_windowRect.x = _window.bounds.x;
				_windowRect.y = _window.bounds.y;
			}
			if (_saveWindowSize)
			{
				_windowRect.width = _window.bounds.width;
				_windowRect.height = _window.bounds.height;
			}
		}
		
		private function window_closingHandler(e:Event):void 
		{
			save();
		}
		
		/**
		 * データを保存する
		 */
		public function save():void 
		{
			if (onBeforeSave != null)
			{
				onBeforeSave();
			}
			
			saveVariableTo(_file);
		}
		
		/**
		 * publicな変数データのみをまとめて保存する
		 * @return
		 */
		public function saveVariableTo(target:File):Boolean
		{
			return LocalFile.writeObject(target, getSaveData(), true, true, _compress);
		}
		
		private function getSaveData():Object 
		{
			var obj:Object = { window: { }, value: { }};
			var ignoreTypes:Array = ["Function"];
			for each(var node:XML in describeType(this)..variable)
			{
				if (ignoreTypes.indexOf(String(node.@type)) >= 0) continue;
				obj.value[node.@name] = this[node.@name];
			}
			obj.window.x = _windowRect.x;
			obj.window.y = _windowRect.y;
			obj.window.width = _windowRect.width;
			obj.window.height = _windowRect.height;
			obj.window.maximized = _windowMaximized;
			
			return obj;
		}
		
		/**
		 * 保存してからアプリケーションを閉じる。
		 */
		public function saveAndClose():void 
		{
			save();
			NativeApplication.nativeApplication.exit();
		}
		
	}

}