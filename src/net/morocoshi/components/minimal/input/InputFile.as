package net.morocoshi.components.minimal.input 
{
	import com.bit101.components.Component;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.menu.AirMenu;

	/**
	 * ファイルパス入力コンポーネント。参照ボタンでダイアログを開いてファイルを選択できる。ファイルやフォルダのドロップでも設定できる。
	 * 
	 * @author tencho
	 */
	public class InputFile extends Component
	{
		
		private var isReady:Boolean = false;
		private var _spacing:int = 3;
		private var _labelText:Label;
		private var _button:PushButton;
		private var _input:InputText;
		private var _dragDrop:DragDrop;
		private var _defaultFile:File;
		
		public static const MODE_FOLDER:String = "folder";
		public static const MODE_FILE_SAVE:String = "file_save";
		public static const MODE_FILE_OPEN:String = "file_open";
		
		private var _inputMode:String;
		private var oldLabelWidth:int = -1;
		private var typeFilter:Array;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 * @param	mode
		 */
		public function InputFile(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, mode:String = MODE_FOLDER)
		{
			_inputMode = mode;
			super(parent, xpos, ypos);
			typeFilter = null;
			_labelText = new Label(this, 0, 0);
			_input = new InputText(this, 0, 0);
			_input.textField.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
			_button = new PushButton(this, 0, 0, "参照", browse_clickHandler);
			var menu:AirMenu = new AirMenu();
			menu.addMenuItem("ファイルの場所を開く", "", null, openInputFile);
			_button.contextMenu = menu;
			_input.addEventListener(Event.CHANGE, input_changeHandler);
			isReady = true;
			_dragDrop = new DragDrop();
			_dragDrop.addDropTarget(this);
			_dragDrop.allowFile = true;
			_dragDrop.allowFolder = true;
			_dragDrop.onDragDrop = dropHandler;
			setSize(200, 20);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 余白
		 */
		public function get spacing():int 
		{
			return _spacing;
		}
		
		public function set spacing(value:int):void 
		{
			_spacing = value;
		}
		
		/**
		 * ラベル文字
		 */
		public function get label():String 
		{
			return _labelText.text;
		}
		
		public function set label(value:String):void 
		{
			_labelText.text = value;
		}
		
		/**
		 * 表示テキスト
		 */
		public function get value():* 
		{
			return _input.text;
		}
		
		public function set value(value:*):void 
		{
			_input.text = value;
		}
		
		/**
		 * 参照を押した時の動作モード
		 */
		public function get inputMode():String 
		{
			return _inputMode;
		}
		
		public function set inputMode(value:String):void 
		{
			_inputMode = value;
		}
		
		/**
		 * ドラッグアンドドロップの管理
		 */
		public function get dragDrop():DragDrop 
		{
			return _dragDrop;
		}
		
		/**
		 * 参照クリック時に表示されるファイル
		 */
		public function get defaultFile():File 
		{
			return _defaultFile;
		}
		
		public function set defaultFile(value:File):void 
		{
			_defaultFile = value;
		}
		
		/**
		 * 参照ボタン
		 */
		public function get button():PushButton 
		{
			return _button;
		}
		
		/**
		 * テキスト入力部
		 */
		public function get input():InputText 
		{
			return _input;
		}
		
		//--------------------------------------------------------------------------
		//
		//  設定
		//
		//--------------------------------------------------------------------------
		
		public function setAllowExtension(list:Array):void
		{
			dragDrop.allowExtensions = [];
			var exp:Array = [];
			var ext:Array = [];
			for (var i:int = 0; i < list.length; i++) 
			{
				dragDrop.allowExtensions.push(list[i].toLowerCase());
				exp.push(list[i]);
				ext.push("*." + list[i]);
			}
			typeFilter = list.length? [new FileFilter(exp.join(","), ext.join(";"))] : null;
		}
		
		/**
		 * 入力中のファイルパスの場所を開く
		 */
		private function openInputFile():void 
		{
			var file:File = FileUtil.toFile(_input.text);
			if (!file || !file.parent || !file.exists) return;
			
			if (file.isDirectory)
			{
				file.openWithDefaultApplication();
			}
			else
			{
				file.parent.openWithDefaultApplication();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function input_focusOutHandler(e:FocusEvent):void 
		{
			notifyComplete();
		}
		
		public function notifyComplete():void 
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function notifyChange():void 
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var lw:int = _labelText.width;
			if (oldLabelWidth == lw) return;
			oldLabelWidth = lw;
			setSize(width, height);
		}
		
		private function onNextFrame(e:Event):void 
		{
			removeEventListener(Event.ENTER_FRAME, onNextFrame);
		}
		
		private function dropHandler(clip:ClipData):void 
		{
			if (!clip.fileList.length) return;
			var f:File = clip.fileList[0];
			if (_inputMode != MODE_FOLDER && f.isDirectory) return; 
			if (_inputMode == MODE_FOLDER && !f.isDirectory) return; 
			_input.text = FileUtil.url(f);
			notifyChange();
			notifyComplete();
		}
		
		private function browse_clickHandler(e:Event):void 
		{
			var f:File = FileUtil.toFile(_input.text) || _defaultFile || File.desktopDirectory;
			f.addEventListener(Event.SELECT, path_selectHandler);
			switch(_inputMode)
			{
				case MODE_FOLDER:
					f.browseForDirectory("フォルダを選択");
					break;
				case MODE_FILE_OPEN:
					f.browseForOpen("ファイルを選択", typeFilter);
					break;
				case MODE_FILE_SAVE:
					f.browseForSave("名前を付けて保存");
					break;
				default:
					f.removeEventListener(Event.SELECT, path_selectHandler);
			}
		}
		
		private function path_selectHandler(e:Event):void 
		{
			var f:File = e.currentTarget as File;
			_input.text = f.nativePath;
			notifyComplete();
			notifyChange();
		}
		
		private function input_changeHandler(e:Event):void 
		{
			notifyChange();
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			setSize(value, height);
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			setSize(width, value);
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (!isReady) return;
			var lw:Number = _labelText.text ? _labelText.width + _spacing : 0;
			var bw:int = 40;
			_input.x = lw;
			_input.setSize(w - bw - _spacing - lw, h);
			_button.x = w - bw;
			_button.y = 0;
			_button.setSize(bw, h);
		}
	}

}