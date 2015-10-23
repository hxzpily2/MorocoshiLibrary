package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.InputText;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.filesystem.File;
	import flash.ui.ContextMenu;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	
	/**
	 * DataGrid用のファイルパス参照
	 * 
	 * @author tencho
	 */
	public class GridCellInputFile extends Panel implements IGridCell
	{
		private var _button:PushButton;
		private var _inputText:InputText;
		private var isReady:Boolean = false;
		private var _dragDrop:DragDrop;
		private var _defaultFile:File;
		
		private var _gridItem:DataGridItem;
		
		public static const MODE_FOLDER:String = "folder";
		public static const MODE_FILE_SAVE:String = "file_save";
		public static const MODE_FILE_OPEN:String = "file_open";
			
		private var _inputMode:String = MODE_FILE_OPEN;
		
		/**
		 * コンストラクタ
		 */
		public function GridCellInputFile() 
		{
			super();
			_inputText = new InputText(this, 0, 0);
			_inputText.textField.addEventListener(FocusEvent.FOCUS_OUT, text_focusOutHandler);
			
			var textMenu:ContextMenu = new ContextMenu();
			textMenu.clipboardMenu = true;
			textMenu.addItem(new NativeMenuItem("パスをクリア", false)).addEventListener(Event.SELECT, clear_selectedHandler);
			_inputText.textField.contextMenu = textMenu;
			
			_button = new PushButton(this, 0, 0, "参照", browse_clickHandler);
			_inputText.addEventListener(Event.CHANGE, input_changeHandler);
			isReady = true;
			_dragDrop = new DragDrop();
			_dragDrop.addDropTarget(this);
			_dragDrop.allowFile = true;
			_dragDrop.allowFolder = true;
			_dragDrop.onDragDrop = dropHandler;
		}
		
		private function clear_selectedHandler(e:Event):void 
		{
			_inputText.text = "";
		}
		
		private function text_focusOutHandler(e:FocusEvent = null):void 
		{
			FrameTimer.setTimer(2, scrollMax);
		}
		
		private function scrollMax():void
		{
			_inputText.textField.scrollH = _inputText.textField.maxScrollH;
		}
		
		private function dropHandler(clip:ClipData):void 
		{
			if (!clip.fileList.length) return;
			var f:File = clip.fileList[0];
			if (_inputMode != MODE_FOLDER && f.isDirectory) return; 
			if (_inputMode == MODE_FOLDER && !f.isDirectory) return; 
			_inputText.text = f.nativePath;
			text_focusOutHandler();
			
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		private function browse_clickHandler(e:Event):void 
		{
			var f:File = FileUtil.toFile(_inputText.text) || _defaultFile || File.desktopDirectory;
			f.addEventListener(Event.SELECT, path_selectHandler);
			switch(_inputMode)
			{
				case MODE_FOLDER:
					f.browseForDirectory("フォルダを選択");
					break;
				case MODE_FILE_OPEN:
					f.browseForOpen("ファイルを選択");
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
			_inputText.text = f.nativePath;
			text_focusOutHandler();
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		private function input_changeHandler(e:Event):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		/* INTERFACE net.morocoshi.component.minimal.IGridCell */
		
		public function get cellValue():* 
		{
			return _inputText.text;
		}
		
		public function set cellValue(value:*):void 
		{
			_inputText.text = value;
		}
		
		public function get inputMode():String 
		{
			return _inputMode;
		}
		
		public function set inputMode(value:String):void 
		{
			_inputMode = value;
		}
		
		public function get dragDrop():DragDrop 
		{
			return _dragDrop;
		}
		
		public function get defaultFile():File 
		{
			return _defaultFile;
		}
		
		public function set defaultFile(value:File):void 
		{
			_defaultFile = value;
		}
		
		public function get button():PushButton 
		{
			return _button;
		}
		
		public function get inputText():InputText 
		{
			return _inputText;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (!isReady) return;
			_inputText.setSize(w - 44, h);
			_button.x = w - 42;
			_button.y = 2;
			_button.setSize(40, h - 4);
			text_focusOutHandler();
		}
		
		/* INTERFACE net.morocoshi.components.minimal.grid.IGridCell */
		
		public function get gridItem():DataGridItem 
		{
			return _gridItem;
		}
		
		public function set gridItem(value:DataGridItem):void 
		{
			_gridItem = value;
		}
		
	}

}