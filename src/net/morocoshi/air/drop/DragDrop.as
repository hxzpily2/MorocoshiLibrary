package net.morocoshi.air.drop 
{
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import net.morocoshi.air.files.ClipboardUtil;
	import net.morocoshi.air.files.ClipData;
	
	/**
	 * ウィンドウへのファイルのドラッグ＆ドロップの管理
	 * 
	 * @author tencho
	 */
	public class DragDrop extends EventDispatcher
	{
		/**ドロップ可能なファイル拡張子の配列。小文字で指定。何も指定しないと全拡張子がドロップ可能になる。*/
		public var allowExtensions:Array = [];
		/**エクスプローラ等からファイルがドロップ可能か*/
		public var allowFile:Boolean = false;
		/**エクスプローラ等からフォルダがドロップ可能か*/
		public var allowFolder:Boolean = false;
		/**AIR経由でのドロップ？詳細不明*/
		public var allowBitmapData:Boolean = false;
		/**WEBブラウザ等から画像がドロップ可能か*/
		public var allowImagePath:Boolean = false;
		/**テキストをドロップ可能か*/
		public var allowText:Boolean = false;
		/**ショートカットファイルもしくはブラウザからのURLがドロップ可能か*/
		public var allowURL:Boolean = false;
		
		/**厳しいドロップ許可ルール*/
		private var strictCheckFunction:Function;
		/**追加のドロップ許可ルール*/
		private var dropCheckFunction:Function;
		
		private var _enabled:Boolean = true;
		private var _isDragOver:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  イベント
		//
		//--------------------------------------------------------------------------
		
		/**ドロップが成功した時にClipDataオブジェクトが渡される*/
		public var onDragDrop:Function;
		/**ドロップ中に対象の描画オブジェクト上にマウスが重なるとtrue、外れるとfalseを返す*/
		public var onDragRoll:Function;
		
		public var stageX:Number = 0;
		public var stageY:Number = 0;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function DragDrop() 
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ドロップ処理が有効か
		 */
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		/**
		 * 対象の上にドラッグ中か
		 */
		public function get isDragOver():Boolean 
		{
			return _isDragOver;
		}
		
		//--------------------------------------------------------------------------
		//
		//  イベント登録
		//
		//--------------------------------------------------------------------------
		
		public function addDropTarget(target:InteractiveObject):void
		{
			target.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragEnterHandler);
			target.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dropHandler);
			target.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER, dragOverHandler);
			target.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragOverHandler);
		}
		
		public function removeDropTarget(target:InteractiveObject):void
		{
			target.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragEnterHandler);
			target.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dropHandler);
			target.removeEventListener(NativeDragEvent.NATIVE_DRAG_OVER, dragOverHandler);
			target.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragOverHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  ルール設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 厳しいドロップ許可ルールを関数で設定する。（関数の引数にClipData）
		 * 関数がfalseを返すと他のルールに関係なくドロップ不能になる。
		 * @param	callback
		 */
		public function setStaticCheck(callback:Function):void
		{
			strictCheckFunction = callback;
		}
		
		/**
		 * 追加のドロップ許可ルールを関数で設定する。（関数の引数にClipData）
		 * 関数がfalseを返しても他のルールが有効ならドロップ可能。
		 * @param	callback
		 */
		public function setDropCheck(callback:Function):void
		{
			dropCheckFunction = callback;
		}
		
		/**
		 * 全ての種類をドロップ可能にする（拡張子リストと追加のルールと厳しいルールを上書き）
		 */
		public function allowAll():void
		{
			setStaticCheck(null);
			setDropCheck(null);
			allowExtensions = [];
			allowFile = true;
			allowFolder = true;
			allowBitmapData = true;
			allowImagePath = true;
			allowText = true;
			allowURL = true;
		}
		
		/**
		 * 全ての種類をドロップ不可にする（拡張子リストと追加のルールと厳しいルールを上書き）
		 */
		public function denyAll():void
		{
			setStaticCheck(null);
			setDropCheck(null);
			allowExtensions = [];
			allowFile = false;
			allowFolder = false;
			allowBitmapData = false;
			allowImagePath = false;
			allowText = false;
			allowURL = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function dragOverHandler(e:NativeDragEvent):void 
		{
			stageX = e.stageX;
			stageY = e.stageY;
			var over:Boolean = (e.type == NativeDragEvent.NATIVE_DRAG_OVER);
			if (over == _isDragOver) return;
			_isDragOver = over;
			
			var event:DropEvent = new DropEvent(DropEvent.DRAG_ROLL);
			event.isDragOver = _isDragOver;
			dispatchEvent(event);
			
			if (onDragRoll != null)
			{
				onDragRoll(_isDragOver);
			}
		}
		
		private function dropHandler(e:NativeDragEvent):void 
		{
			dragOverHandler(e);
			var clip:ClipData = ClipboardUtil.getClipboard(e.clipboard);
			clip.fileList = extractFolder(clip.fileList).concat(extractAllowedExtension(clip.fileList));
			var event:DropEvent = new DropEvent(DropEvent.DRAG_DROP);
			event.clipData = clip;
			dispatchEvent(event);
			
			if (onDragDrop != null)
			{
				onDragDrop(clip);
			}
		}
		
		private function dragEnterHandler(e:NativeDragEvent):void 
		{
			var data:ClipData = ClipboardUtil.getClipboard(e.clipboard);
			
			var fld:Boolean = allowFolder && (extractFolder(data.fileList).length > 0);
			var ext:Boolean = allowFile && (extractAllowedExtension(data.fileList).length > 0);
			var bmd:Boolean = allowBitmapData && Boolean(data.bitmapData);
			var img:Boolean = allowImagePath && Boolean(data.imagePath);
			var url:Boolean = allowURL && data.urlList.length;
			var str:Boolean = strictCheckFunction == null || strictCheckFunction(data);
			var chk:Boolean = dropCheckFunction != null && dropCheckFunction(data);
			
			if (str && (fld || ext || bmd || img || url || chk)) NativeDragManager.acceptDragDrop(e.currentTarget as InteractiveObject);
		}
		
		private function extractFolder(fileList:Vector.<File>):Vector.<File>
		{
			var result:Vector.<File> = new Vector.<File>;
			
			//許可してない場合は空の配列を返す
			if (allowFolder == false)
			{
				return result;
			}
			
			for each(var file:File in fileList)
			{
				if (file.isDirectory)
				{
					result.push(file);
				}
			}
			return result;
		}
		
		/**
		 * 
		 * @param	fileList
		 * @return
		 */
		private function extractAllowedExtension(fileList:Vector.<File>):Vector.<File>
		{
			var result:Vector.<File> = new Vector.<File>;
			var file:File;
			
			//許可してない場合は空の配列を返す
			if (allowFile == false)
			{
				return result;
			}
			
			//allowExtensions未設定の時はフォルダを省いた全ファイルを返す
			if (!allowExtensions || !allowExtensions.length)
			{
				for each(file in fileList)
				{
					if (file.isDirectory == false)
					{
						result.push(file);
					}
				}
				return result;
			}
			
			//一致する拡張子のファイルを抽出
			for each(file in fileList)
			{
				var match:Boolean = allowExtensions.some(function(...rest):Boolean
				{
					var ext:String = file.extension || "";
					return (rest[0] == ext.toLowerCase());
				});
				if (match)
				{
					result.push(file);
				}
			}
			return result;
		}
		
	}

}