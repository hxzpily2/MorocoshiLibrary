package net.morocoshi.components.tree
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenu;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.describeType;
	
	/**
	 * ツリーアイテムクラス。
	 * ファイルやフォルダにあたるクラスです。
	 * 
	 * @author	tencho
	 */
	public class TreeLimb extends Sprite
	{
		private var _itemContainer:Sprite;
		private var _switchContainer:Sprite;
		private var _openSprite:Sprite;
		private var _closeSprite:Sprite;
		private var _iconSprite:Sprite;
		private var _openIcon:Bitmap;
		private var _closeIcon:Bitmap;
		private var _labelText:TextField;
		private var _limbs:Sprite;
		private var _lineV:Sprite;
		private var _lineH:Sprite;
		private var _selectBox:Sprite;
		
		private var _extra:*;
		private var _icon:String;
		private var _label:String;
		private var _isFolder:Boolean;
		private var _isOpen:Boolean = true;
		private var _selected:Boolean = false;
		private var _multiSelect:Boolean = true;
		private var _selectable:Boolean = true;
		private var _closable:Boolean = true;
		private var _hideRoot:Boolean = false;
		private var _isRoot:Boolean = true;
		private var _itemVisible:Boolean = true;
		private var _style:TreeStyle;
		
		private var _parentLimb:TreeLimb;
		private var _rootLimb:TreeLimb;
		private var _selectedItems:Vector.<TreeLimb>;	//[root専用]	選択されているアイテムリスト
		
		private var _lastParent:DisplayObjectContainer;
		private var _lastLineVisible:Boolean = true;	//最新の横線表示状況
		private var _lastBounds:Rectangle;	//最新の自分の子を含む矩形サイズ
		private var _lastVisibleCount:int = -1;	//最新の見えているフォルダ数
		private var _lastIcon:String = "";	//最新のアイコン
		
		private var _isUpdateStyleOnce:Boolean = false;
		private var _isUpdatedOnce:Boolean = false;
		private var _isAdding:Boolean = false;	//addLimb()等で追加されたオブジェクトか
		private var _isGhost:Boolean = false;	//既に破棄されたアイテムか
		private var _isDirtyChild:Boolean = true;	//自分の子も更新対象にするか
		///private var _isDirtyVisibleCount:Boolean = true;	//見えているフォルダの数が変化した
		private var _isShiftKey:Boolean = false;	//[root専用]
		private var _isCtrlKey:Boolean = false;	//[root専用]
		private var _lastClickItem:TreeLimb;	//[root専用]最後にクリックしたアイテム
		private var _isLock:Boolean;	//[root専用]表示の更新を無効にする
		private var _isNewStyle:Boolean = false;	//スタイルが新しくなった
		private var selectBoxMargin:Number = 3;
		private var _visible:Boolean = true;
		
		private function updateVisible():void 
		{
			super.visible = _visible && _itemVisible;
		}
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	label	ラベルテキスト
		 * @param	isFolder	フォルダアイコンを使うか
		 * @param	icon	ファイルアイコンの種類（isFolder=trueで無効、空文字でアイコン無し）
		 * @param	extra	ユーザーデータ
		 */
		public function TreeLimb(label:String = "New Item", isFolder:Boolean = true, icon:String = "", extra:* = null)
		{
			if (label == null) label = "";
			_style = new TreeStyle();
			_selectedItems = new Vector.<TreeLimb>();
			_lineV = addChild(new Sprite()) as Sprite;
			_lineH = addChild(new Sprite()) as Sprite;
			_itemContainer = addChild(new Sprite()) as Sprite;
			_selectBox = _itemContainer.addChild(new Sprite()) as Sprite;
			_selectBox.graphics.beginFill(0xBE9852, 1);
			_selectBox.graphics.drawRect(0, 0, 100, 10);
			_switchContainer = _itemContainer.addChild(new Sprite()) as Sprite;
			_openSprite = _switchContainer.addChild(new Sprite()) as Sprite;
			_closeSprite = _switchContainer.addChild(new Sprite()) as Sprite;
			_closeSprite.mouseEnabled = false;
			_openSprite.addEventListener(MouseEvent.CLICK, onClickOpen);
			_openSprite.buttonMode = true;
			_iconSprite = _itemContainer.addChild(new Sprite()) as Sprite;
			_labelText = _itemContainer.addChild(new TextField()) as TextField;
			_labelText.autoSize = TextFieldAutoSize.LEFT;
			_labelText.selectable = false;
			_limbs = addChild(new Sprite()) as Sprite;
			_iconSprite.buttonMode = _selectBox.buttonMode = true;
			_iconSprite.doubleClickEnabled = _selectBox.doubleClickEnabled = true;
			_iconSprite.addEventListener(MouseEvent.CLICK, onClickItem);
			_iconSprite.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onClickItem);
			_iconSprite.addEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
			_selectBox.addEventListener(MouseEvent.CLICK, onClickItem);
			_selectBox.addEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
			_selectBox.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onClickItem);
			_label = label;
			_labelText.text = _label;
			_labelText.mouseEnabled = false;
			_isFolder = isFolder;
			_icon = icon;
			_extra = extra;
			checkRoot(true);
			addEventListener(Event.ADDED, onAdded);
			addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**[g/s]ユーザーデータ*/
		public function get extra():* { return _extra; }
		public function set extra(value:*):void { _extra = value; }
		/**[g/s]ラベルテキスト*/
		public function get label():String { return _label; }
		public function set label(value:String):void { _labelText.text = _label = value; updateLabel(); }
		/**[g/s]フォルダアイコンを使うか*/
		public function get isFolder():Boolean { return _isFolder; }
		public function set isFolder(value:Boolean):void { _isFolder = value; updateIcon(); }
		/**[g/s]ファイルアイコンの種類（isFolder=trueで無効、-1でアイコン無し）*/
		public function get icon():String { return _icon; }
		public function set icon(value:String):void { _icon = value; updateStyle(); }
		/**[g/s]自分が選択されているか*/
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void { setSelect(value, true); }
		/**[g/s]サブフォルダを開いているか*/
		public function get isOpen():Boolean { return _isOpen; }
		public function set isOpen(value:Boolean):void { setOpen(value); }
		/**[g]ルートフォルダ*/
		public function get rootLimb():TreeLimb { return _rootLimb; }
		/**[g]親のTreeLimbオブジェクト*/
		public function get parentLimb():TreeLimb { return _parentLimb; }
		/**[q]自分がルートフォルダか*/
		public function get isRoot():Boolean { return _isRoot; }
		/**[g]スタイル*/
		public function get style():TreeStyle { return _style; }
		/**[q]子の数*/
		public function get numChildLimb():int { return _limbs.numChildren; }
		/**[g/s][root専用]マウス操作で複数選択が可能か*/
		public function get multiSelect():Boolean { return _rootLimb._multiSelect; }
		public function set multiSelect(value:Boolean):void { _rootLimb._multiSelect = value; }
		/**[g/s][root専用]マウス操作で選択が可能か*/
		public function get selectable():Boolean { return _rootLimb._selectable; }
		public function set selectable(value:Boolean):void { _rootLimb._selectable = value; }
		/**[g/s][root専用]ルートフォルダを隠して複数ルートフォルダがあるように見せる*/
		public function get hideRoot():Boolean { return _rootLimb._hideRoot; }
		public function set hideRoot(value:Boolean):void { _rootLimb._hideRoot = value; }
		/**[g/s][root専用]マウス操作でフォルダの開閉を弄れるか*/
		public function get closable():Boolean { return _rootLimb._closable; }
		public function set closable(value:Boolean):void { _rootLimb._closable = value; }
		/**[g/s]*/
		public function get itemVisible():Boolean { return _itemVisible; }
		public function set itemVisible(value:Boolean):void
		{
			_itemVisible = value;
			updateVisible();
			updateDirty();
		}
		
		override public function get visible():Boolean 
		{
			return _visible;
		}
		
		override public function set visible(value:Boolean):void 
		{
			_visible = value;
			updateVisible();
		}
		
		public function get labelText():TextField 
		{
			return _labelText;
		}
		
		//--------------------------------------------------------------------------
		//
		//  メイン処理
		//
		//--------------------------------------------------------------------------
		
		public function setKeyEvent(target:InteractiveObject):void
		{
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
			target.addEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
		}
		
		private function keyUpDownHandler(e:KeyboardEvent):void 
		{
			var isDown:Boolean = (e.type == KeyboardEvent.KEY_DOWN);
			if (!isDown) return;
			switch(e.keyCode)
			{
				case Keyboard.UP:
					moveSelected(-1);
					break;
				case Keyboard.DOWN:
					moveSelected(1);
					break;
			}
		}
		
		public function moveSelected(offset:int):void
		{
			var d:int = (offset < 0)? -1 : 1;
			var selected:Vector.<TreeLimb> = getSelectedLimbs();
			if (selected.length != 1) return;
			
			var item:TreeLimb = selected[0];
			var activeItem:TreeLimb = item.parentLimb;
			var i:int = item.getIndex() + offset;
			
			if (d == 1 && item.numChildLimb && item.isOpen)
			{
				activeItem = item;
				i = 0;
			}
			if (!activeItem) return;
			
			var num:int = activeItem.numChildLimb - 1;
			var up:Boolean = false;
			while (true)
			{
				if (i < 0 || i > num)
				{
					i = activeItem.getIndex() + int(i > num);
					activeItem = activeItem.parentLimb;
					if (!activeItem) break;
					num = activeItem.numChildLimb - 1;
					up = true;
				}
				var limb:TreeLimb = activeItem.getLimbAt(i);
				if (!limb) break;
				if (limb.itemVisible)
				{
					if (!up && d == -1 && limb.numChildLimb && limb.isOpen && limb.itemVisible)
					{
						limb = limb.getLimbAt(limb.numChildLimb - 1);
						i = limb.getIndex();
					}
					if (limb.itemVisible)
					{
						limb.setSelect(true, false, true);
						break;
					}
				}
				else
				{
					i += d;
				}
			}
		}
		
		/**
		 * 繋がっているアイテムの全ての選択を解除
		 * @param	dispatch	CHANGE_SELECTイベントを発生させるか
		 */
		public function deselectAll(dispatch:Boolean = true):void
		{
			while(_rootLimb._selectedItems.length) _rootLimb._selectedItems[0].setSelect(false, false, false);
			if (dispatch) _rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
		}
		
		/**
		 * 自分を選択/解除
		 * @param	selected	選択するかどうか
		 * @param	multiSelect	trueで追加選択モード。falseで他に選択しているものがあれば解除される。
		 * @param	dispatch	CHANGE_SELECTイベントを発生させるか
		 */
		public function setSelect(selected:Boolean = true, multiSelect:Boolean = false, dispatch:Boolean = true):void
		{
			if (selected && !multiSelect) deselectAll(false);
			_selected = selected;
			var index:int = _rootLimb._selectedItems.indexOf(this);
			var select:Boolean = false;
			if (_selected && index == -1)
			{
				select = true;
				_rootLimb._selectedItems.push(this);
			}
			if (!_selected && index != -1) _rootLimb._selectedItems.splice(index, 1);
			updateSelect();
			if(select) _rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.SELECT_ITEM, this));
			if (dispatch)
			{
				_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
			}
		}
		
		/**
		 * フォルダの開閉
		 * @param	isOpen	開くかどうか
		 * @param	subLimbs	サブフォルダ以下も開閉するか
		 */
		public function setOpen(open:Boolean = true, subLimbs:Boolean = false):void
		{
			_isOpen = open;
			
			if (subLimbs)
			{
				for each(var limb:TreeLimb in getChildLimbs(true))
				{
					limb.setOpen(open, subLimbs);
				}
			}
			updateDirty();
			
			_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.SWITCH, this));
		}
		
		/**
		 * フォルダを開く
		 */
		public function open(subLimbs:Boolean = false):void
		{
			setOpen(true);
			if (subLimbs)
			{
				for each(var f:TreeLimb in getChildLimbs())
				{
					f.open(subLimbs);
				}
			}
		}
		
		/**
		 * フォルダを閉じる
		 */
		public function close(subLimbs:Boolean = false):void
		{
			setOpen(false);
			if (subLimbs)
			{
				for each(var f:TreeLimb in getChildLimbs())
				{
					f.close(subLimbs);
				}
			}
		}
		
		/**
		 * 選択されている全てのアイテムを取得
		 */
		public function getSelectedLimbs():Vector.<TreeLimb>
		{
			return _rootLimb._selectedItems.sort(sortFunc);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		private function onRemoveStage(e:Event):void
		{
			if (this === _rootLimb._lastClickItem)
			{
				_rootLimb._lastClickItem = null;
			}
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyUpDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpDown);
		}
		
		private function onAddedStage(e:Event):void
		{
			if (_isRoot)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUpDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpDown);
			}
		}
		
		private function onKeyUpDown(e:KeyboardEvent):void
		{
			_isShiftKey = e.shiftKey;
			_isCtrlKey = e.ctrlKey;
		}
		
		private function onAdded(e:Event):void
		{
			if (!checkRoot()) return;
			//addLimb系メソッドを使わずaddChildしている時
			if (!_isAdding) updateOnce();
		}
		
		private function onClickOpen(e:MouseEvent):void
		{
			setOpen(!_isOpen);
		}
		
		private function onClickItem(e:MouseEvent):void
		{
			clickItem();
			_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
			_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CLICK_ITEM, this));
		}
		
		private function clickItem():void
		{
			if (_rootLimb._selectable)
			{
				//何か選択している状態で、前回と同じ階層で、SHIFTを押している場合
				if (_rootLimb._multiSelect && _parentLimb && _rootLimb._lastClickItem != null && _rootLimb._isShiftKey && _rootLimb._lastClickItem.parent == parent)
				{
					var index1:int = _rootLimb._lastClickItem.getIndex();
					var index2:int = getIndex();
					if (index1 > index2)
					{
						var tmp:int = index2;
						index2 = index1;
						index1 = tmp;
					}
					if (!_rootLimb._isCtrlKey) deselectAll(false);
					for (var i:int = index1; i <= index2; i++)
					{
						_parentLimb.getLimbAt(i).setSelect(true, true, false);
					}
				}
				else
				{
					//CTRLを押していたら選択のONOFF切り替え。そうでなければONにする。
					if (_rootLimb._isCtrlKey && (_selected || _rootLimb._multiSelect))
					{
						setSelect(!_selected, true, false);
					}
					else
					{
						setSelect(true, false, false);
					}
					_rootLimb._lastClickItem = this;
				}
			}
		}
		
		private function onWclickIcon(e:MouseEvent):void
		{
			clickItem();
			if (_rootLimb._closable)
			{
				setOpen(!_isOpen);
			}
			_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.WCLICK_ITEM, this));
		}
		
		private function getRoot():TreeLimb
		{
			return (_parentLimb == null)? this : _parentLimb.getRoot();
		}
		
		/**
		 * 親が変化している場合はルートを再設定する
		 * @param	exe	trueにすると親が変化したかに関わらずルートを再設定する
		 * @return	親が変化していたらtrue
		 */
		private function checkRoot(exe:Boolean = false):Boolean
		{
			if (parent === _lastParent && !exe) return false;
			
			_lastParent = parent;
			_parentLimb = (parent == null || parent.parent == null)? null : parent.parent as TreeLimb;
			_rootLimb = getRoot();
			_isRoot = _rootLimb === this;
			
			for each(var l:TreeLimb in getChildLimbs())
			{
				l.checkRoot(true);
			}
			
			return true;
		}
		
		private function sortFunc(a:TreeLimb, b:TreeLimb):int
		{
			return a.getIndex() - b.getIndex();
		}
		
		/**
		 * 自分のインデックス位置を取得
		 * @return
		 */
		public function getIndex():int
		{
			return (!parent)? 0 : parent.getChildIndex(this);
		}
		
		/**
		 * 全ての親を取得する（親に親がいたらそれも取得）
		 * @return
		 */
		public function getParentLimbs():Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			
			if (!isRoot)
			{
				result.push(_parentLimb);
				result = result.concat(_parentLimb.getParentLimbs());
			}
			
			return result;
		}
		
		/**
		 * 自分の表示状態に位置が影響される全てのアイテムを取得する
		 * @return
		 */
		private function getUpdateLimbs():Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			
			if (_isRoot)
			{
				result.push(this);
			}
			if (_parentLimb)
			{
				var leng:int = _parentLimb.numChildLimb;
				for (var i:int = getIndex(); i < leng; i++)
				{
					result.push(_parentLimb.getLimbAt(i) as TreeLimb);
				}
				result = result.concat(_parentLimb.getUpdateLimbs());
			}
			
			return result;
		}
		
		/**
		 * 自分の子のリストを取得
		 * @param	subLimbs	孫以降も取得するか
		 * @param	addMe	自分も含めるか
		 * @return
		 */
		public function getChildLimbs(subLimbs:Boolean = false, addMe:Boolean = false):Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			var leng:int = numChildLimb;
			
			for (var i:int = 0; i < leng; i++)
			{
				var limb:TreeLimb = getLimbAt(i);
				result.push(limb);
				if (subLimbs)
				{
					result = result.concat(limb.getChildLimbs(subLimbs));
				}
			}
			if (addMe)
			{
				result.push(this);
			}
			
			return result;
		}
		
		/**
		 * ユーザーデータが一致する全ての子を取得
		 * @param	extra
		 * @param	subLimbs	孫以降も検索するか
		 * @return
		 */
		public function getLimbByExtra(extra:*, subLimbs:Boolean = true):Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			
			for each(var limb:TreeLimb in getChildLimbs(subLimbs))
			{
				if (limb.extra === extra)
				{
					result.push(limb);
				}
			}
			
			return result;
		}
		
		/**
		 * ラベル名が一致する全ての子を取得
		 * @param	label
		 * @param	subLimbs	孫以降も検索するか
		 * @return
		 */
		public function getLimbByLabel(label:String, subLimbs:Boolean = true):Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			
			for each(var limb:TreeLimb in getChildLimbs(subLimbs))
			{
				if (limb._label == label)
				{
					result.push(limb);
				}
			}
			
			return result;
		}
		
		/**
		 * 指定インデックスの子を取得
		 * @param	index
		 * @return
		 */
		public function getLimbAt(index:int):TreeLimb
		{
			return (index < 0 || index >= numChildLimb)? null : _limbs.getChildAt(index) as TreeLimb;
		}
		
		/**
		 * TreeLimbオブジェクトを子に追加
		 * @param	limb
		 * @return
		 */
		public function addLimb(limb:TreeLimb):TreeLimb
		{
			return addLimbAt(limb, numChildLimb);
		}
		
		/**
		 * 複数のTreeLimbオブジェクトを子に追加
		 * @param	limbs	追加するTreeLimbオブジェクトの配列
		 * @param	checkOverlap	配列内で親子関係のあるアイテムがあった場合、親だけを追加して親子関係が崩れないようにする
		 * @return	追加した分のTreeLimbリスト
		 */
		public function addLimbs(limbs:Vector.<TreeLimb>, checkOverlap:Boolean = true):Vector.<TreeLimb>
		{
			var list:Vector.<TreeLimb>;
			
			if (checkOverlap)
			{
				list = TreeUtil.adjustFamily(limbs);
			}
			else
			{
				list = limbs.concat();
			}
			
			while (list.length)
			{
				addLimb(list.shift());
			}
			
			return limbs;
		}
		
		/**
		 * TreeLimbオブジェクトを指定インデックスに子に追加
		 * @param	limb
		 * @param	index
		 * @return
		 */
		public function addLimbAt(limb:TreeLimb, index:int = -1):TreeLimb
		{
			for each(var l:TreeLimb in limb.getChildLimbs(true, true))
			{
				if (l.selected)
				{
					l.setSelect(false);
				}
			}
			
			limb._isAdding = true;
			
			if (limb._parentLimb === this)
			{
				limb.parent.removeChild(limb);
			}
			if (index > numChildLimb || index < 0)
			{
				index = numChildLimb;
			}
			if (limb.parent != null)
			{
				limb.remove();
			}
			
			_limbs.addChildAt(limb, index);
			limb.newStyle(_style, true);
			limb.updateDirty();
			
			if (_hideRoot && _rootLimb.numChildLimb > 0)
			{
				_rootLimb.getLimbAt(0).checkShowLine();
			}
			else
			{
				_rootLimb.checkShowLine();
			}
			
			limb.update();
			limb._isAdding = false;
			
			return limb;
		}
		
		/**
		 * ファイルを子に追加
		 * @param	label
		 * @param	icon
		 * @param	extra
		 * @return
		 */
		public function addFile(label:String = "", icon:String = "", extra:* = null):TreeLimb
		{
			return addLimb(new TreeLimb(label, false, icon, extra));
		}
		
		/**
		 * フォルダも含んだパスを使ってTreeLimbファイルを追加する。
		 * @param	path
		 * @param	separator
		 * @param	icon
		 * @param	extra
		 */
		public function addFilePath(path:String, separator:String = "/", icon:String = "", extra:* = null):TreeLimb 
		{
			var list:Array = path.split(separator);
			var file:String = list.pop();
			var target:TreeLimb = this;
			for (var i:int = 0; i < list.length; i++) 
			{
				var items:Vector.<TreeLimb> = target.getLimbByLabel(list[i], false);
				target = items.length? items[0] : target.addFolder(list[i]);
			}
			return target.addFile(file, icon, extra);
		}
		
		/**
		 * フォルダも含んだパスを使ってTreeLimbフォルダを追加する。
		 * @param	path
		 * @param	separator
		 * @param	extra
		 */
		public function addFolderPath(path:String, separator:String = "/", extra:* = null):TreeLimb 
		{
			if (path.charAt(path.length - 1) == separator)
			{
				path = path.substr(0, path.length - 1);
			}
			var list:Array = path.split(separator);
			var target:TreeLimb = this;
			for (var i:int = 0; i < list.length; i++) 
			{
				var items:Vector.<TreeLimb> = target.getLimbByLabel(list[i], false);
				target = items.length? items[0] : target.addFolder(list[i]);
			}
			if (target != this)
			{
				target.extra = extra;
			}
			return target;
		}
		
		/**
		 * 複数のファイルを子に追加
		 * @param	labels
		 * @param	icons
		 * @param	extras
		 * @return
		 */
		public function addFiles(labels:Array, icons:Array = null, extras:Array = null):Vector.<TreeLimb>
		{
			if (icons == null) icons = new Array();
			if (extras == null) extras = new Array();
			while (icons.length < labels.length) icons.push(0);
			while (extras.length < labels.length) extras.push(null);
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			for (var i:int = 0; i < labels.length; i++)
			{
				result.push(addFile(labels[i], icons[i], extras[i]));
			}
			return result;
		}
		
		/**
		 * フォルダを子に追加
		 * @param	label
		 * @param	extra
		 * @return
		 */
		public function addFolder(label:String = "", extra:* = null):TreeLimb
		{
			return addLimb(new TreeLimb(label, true, "", extra));
		}
		
		/**
		 * 複数のフォルダを子に追加
		 * @param	labels
		 * @param	extras
		 * @return
		 */
		public function addFolders(labels:Array, extras:Array = null):Vector.<TreeLimb>
		{
			if (extras == null) extras = new Array();
			while (extras.length < labels.length)
			{
				extras.push(null);
			}
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			for (var i:int = 0; i < labels.length; i++)
			{
				result.push(addFolder(labels[i], extras[i]));
			}
			return result;
		}
		
		/**
		 * 自分の子のTreeLimbオブジェクトを全て切り離す
		 */
		public function removeAllChildren():void
		{
			removeChildLimbs(getChildLimbs());
		}
		
		/**
		 * TreeLimbオブジェクトを自分から切り離す
		 * @param	limb
		 * @return
		 */
		public function removeChildLimb(limb:TreeLimb):Boolean
		{
			for each(var l:TreeLimb in getChildLimbs(true, true))
			{
				if (l === limb)
				{
					l.remove();
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 複数のTreeLimbオブジェクトを子から切り離す
		 * @param	limbs
		 * @return
		 */
		public function removeChildLimbs(limbs:Vector.<TreeLimb>):int
		{
			var count:int = 0;
			for each(var l:TreeLimb in limbs)
			{
				count += int(l.removeChildLimb(l));
			}
			return count;
		}
		
		/**
		 * 内部データを破棄する
		 * @param	subLimbs
		 */
		private function destroyData(subLimbs:Boolean = true):void
		{
			removeAllListeners();
			_extra = null;
			_selected = false;
			_isGhost = true;
			_selectedItems.length = 0;
			_lastClickItem = null;
			if (subLimbs)
			{
				for each(var l:TreeLimb in getChildLimbs())
				{
					l.destroyData(true);
				}
			}
		}
		
		/**
		 * 自分を破棄する
		 * @param	subLimbs
		 */
		public function dispose(subLimbs:Boolean = true):void
		{
			remove();
			destroyData(subLimbs);
		}
		
		/**
		 * 自分を親から切り離す
		 * @return
		 */
		public function remove():Boolean
		{
			for each(var l:TreeLimb in getChildLimbs(true, true))
			{
				if(l.selected) l.setSelect(false);
			}
			if (parent == null) return false;
			
			parent.removeChild(this);
			if (!isRoot && !_rootLimb._isGhost) updateDirty();
			checkRoot(true);
			return true;
		}
		
		/**
		 * 内部イベントリスナを全て削除
		 */
		public function removeAllListeners():void
		{
			removeEventListener(Event.ADDED, onAdded);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
			_iconSprite.removeEventListener(MouseEvent.CLICK, onClickItem);
			_iconSprite.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
			_selectBox.removeEventListener(MouseEvent.CLICK, onClickItem);
			_selectBox.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
			_openSprite.removeEventListener(MouseEvent.CLICK, onClickOpen);
		}
		
		/**
		 * 自分の子をソートして再配置(Array.sortOn()と同じ)
		 * @param	names
		 * @param	options
		 */
		public function sortOnChild(names:String, options:Object = null):void
		{
			var list:Array = new Array();
			for each(var l:TreeLimb in getChildLimbs()) list.push(l);
			list.sortOn(names, options);
			var sortedLimbs:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			for each(var limb:TreeLimb in list) sortedLimbs.push(limb);
			addLimbs(sortedLimbs);
		}
		
		/**
		 * 自分の子をソートして再配置(Array.sort()と同じ)
		 * @param	func
		 */
		public function sortChild(func:Function):void
		{
			var list:Array = new Array();
			for each(var l:TreeLimb in getChildLimbs()) list.push(l);
			list.sort(func);
			var sortedLimbs:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			for each(var limb:TreeLimb in list) sortedLimbs.push(limb);
			addLimbs(sortedLimbs);
		}
		
		/**
		 * 繋がった全てのアイテムの表示の更新を無効にする
		 */
		public function lock():void
		{
			_rootLimb._isLock = true;
		}
		
		/**
		 * 繋がった全てのアイテムの表示の更新を有効にする
		 */
		public function unlock():void
		{
			if (!_rootLimb._isLock) return;
			_rootLimb._isLock = false;
			
			for each(var limb:TreeLimb in _rootLimb.getChildLimbs(true, true))
			{
				limb.newStyle(limb.style, false);
			}
		}
		
		/**
		 * 繋がった全てのアイテムにスタイルを適用
		 * @param	style	スタイル
		 */
		public function setStyle(style:TreeStyle):void
		{
			_rootLimb.newStyle(style, true);
		}
		
		/**
		 * 繋がった全てのアイテムのスタイルを更新
		 */
		public function updateAllStyle():void
		{
			setStyle(_style);
		}
		
		/**
		 * スタイルを適用する
		 * @param	style	スタイル
		 * @param	subLimbs	サブフォルダ以下も適用するか
		 */
		public function newStyle(style:TreeStyle, subLimbs:Boolean = true):void
		{
			_style = style;
			_isNewStyle = true;
			updateStyle();
			updateSelect();
			if (subLimbs)
			{
				for each(var l:TreeLimb in getChildLimbs())
				{
					l.newStyle(_style, subLimbs);
				}
			}
			update();
		}
		
		/**
		 * 選択状況の見た目を更新する
		 */
		private function updateSelect():void
		{
			if (_rootLimb._isLock) return;
			
			_labelText.textColor = (_selected)? _style.selectedLabelColor : uint(_style.textFormat.color);
			_selectBox.alpha = int(_selected);
		}
		
		/**
		 * 変化したものだけ表示を更新する
		 */
		private function updateDirty():void
		{
			_lastVisibleCount = -1;
			for each(var tl1:TreeLimb in getParentLimbs())
			{
				tl1._lastVisibleCount = -1;
			}
			if (_rootLimb._isLock) return;
			for each(var tl2:TreeLimb in getUpdateLimbs())
			{
				tl2._isDirtyChild = false;
				tl2.update(true);
			}
		}
		
		/**
		 * 初回のみ表示を更新する
		 */
		private function updateOnce():void
		{
			if (_isUpdatedOnce) return;
			_isUpdatedOnce = true;
			updateStyleOnce();
			update();
		}
		
		/**
		 * 表示を更新する
		 * @param	subLimbs	サブフォルダ以下も更新する
		 */
		private function update(subLimbs:Boolean = true):void
		{
			if (_rootLimb._isLock) return;
			updateStyleOnce();
			checkShowLine();
			var lineHeight:Number = 0;
			var heightList:Array = new Array();
			var numChild:int = numChildLimb;
			if (_isOpen && subLimbs)
			{
				var nextY:Number = 0;
				for (var i:int = 0; i < numChild; i++ )
				{
					var limb:TreeLimb = _limbs.getChildAt(i) as TreeLimb;
					if (limb._itemVisible)
					{
						limb.x = 0;
						limb.y = nextY;
						if (_isDirtyChild) limb.update(subLimbs);
						var h:Number = limb.getVisibleCount() * _style.lineSpacing;
						heightList.push(h);
						nextY += h;
					}
				}
				for (i = 0; i < heightList.length; i++ )
				{
					lineHeight += (i == heightList.length - 1)? _style.lineSpacing : heightList[i];
				}
				/*
				heightList.forEach(function(...arg):void {
					lineHeight += (arg[1] == heightList.length - 1)? _style.lineSpacing : arg[0];
				});
				*/
			}
			
			//ルートを隠すモードの場合は縦線の高さを調整
			if (_isRoot && _hideRoot && numChild > 0) lineHeight -= _style.lineSpacing;
			updateIcon();
			_limbs.visible = _isOpen;
			_openSprite.visible = (numChildLimb > 0);
			_closeSprite.visible = _openSprite.visible && !_isOpen;
			_lineV.graphics.clear();
			_lineV.graphics.beginBitmapFill(_style.dotV);
			_lineV.graphics.drawRect(0, 0, 1, lineHeight);
			_lineV.graphics.endFill();
			
			if (_isRoot)
			{
				var rect:Rectangle = getVisibleRect();
				if (_lastBounds == null || !rect.equals(_lastBounds))
				{
					var event:TreeLimbEvent = new TreeLimbEvent(TreeLimbEvent.RESIZE, this);
					event.bounds = rect.clone();
					dispatchEvent(event);
					_lastBounds = rect;
				}
			}
			_isDirtyChild = false;
		}
		
		/**
		 * 一度だけスタイルを更新
		 */
		private function updateStyleOnce():void
		{
			if (_isUpdateStyleOnce) return;
			_isUpdateStyleOnce = true;
			updateStyle();
		}
		
		/**
		 * ラベル表示を更新する
		 */
		private function updateLabel():void
		{
			if (_rootLimb._isLock) return;
			_labelText.setTextFormat(_style.textFormat);
			_selectBox.width = _labelText.textWidth + 4;
			_selectBox.height = _labelText.textHeight + selectBoxMargin * 2;
			updateSelect();
		}
		
		/**
		 * 横線を表示するかチェックして、前回と違ったらスタイルを更新
		 */
		private function checkShowLine():void
		{
			var hideMe:Boolean = _hideRoot && _isRoot;
			var hideSub:Boolean = _rootLimb._hideRoot && _parentLimb === _rootLimb && numChildLimb == 0 && _parentLimb.numChildLimb == 1;
			var showLine:Boolean = !(_isRoot && numChildLimb == 0) && !(hideMe || hideSub);
			if (showLine != _lastLineVisible)
			{
				_lastLineVisible = showLine;
				updateStyle();
			}
		}
		
		/**
		 * スタイルに関連する表示を更新する
		 */
		private function updateStyle():void
		{
			if (_rootLimb._isLock) return;
			updateLabel();
			var showLine:Boolean = _lastLineVisible;
			var cornerX:int = _style.treeOffset.x + (int(_style.buttonSize / 2) + _style.lineIndent) * int(showLine);
			_iconSprite.x = cornerX;
			_iconSprite.y = _style.treeOffset.y;
			updateIcon();
			_lineV.x = cornerX;
			_lineH.x = _style.treeOffset.x;
			_lineV.y = _lineH.y = _style.treeOffset.y;
			_lineH.graphics.clear();
			
			if (showLine)
			{
				_lineH.graphics.beginBitmapFill(_style.dotH);
				_lineH.graphics.drawRect(0, 0, int(_style.buttonSize / 2) + _style.lineIndent, 1);
			}
			
			var boxw:Number = _style.buttonSize, thick:Number = 1, linew:Number = Math.max(3, boxw - thick * 2 - 4), lineh:Number = 1;
			_openSprite.graphics.clear();
			for each(var draw:Array in [[0, 0, 0, boxw, boxw], [1, thick, thick, boxw - thick * 2, boxw - thick * 2], [0, (boxw - linew) / 2, (boxw - lineh) / 2, linew, lineh]])
			{
				_openSprite.graphics.beginFill(draw.shift() * 0xFFFFFF);
				_openSprite.graphics.drawRect.apply(null, draw);
			}
			
			_closeSprite.graphics.clear();
			_closeSprite.graphics.beginFill(0);
			_closeSprite.graphics.drawRect((boxw - lineh) / 2, (boxw - linew) / 2, lineh, linew);
			_switchContainer.x = _style.treeOffset.x - (_style.buttonSize-1) / 2;
			_switchContainer.y = _style.treeOffset.y - (_style.buttonSize-1) / 2;
			_labelText.x = cornerX + _style.labelOffset.x;
			_labelText.y = _style.treeOffset.y - _labelText.textHeight / 2 - 2  + _style.labelOffset.y;
			_selectBox.x = _labelText.x;
			_selectBox.y = _labelText.y + 3 - selectBoxMargin;
			var ct:ColorTransform = new ColorTransform();
			ct.color = _style.selectedBoxColor;
			ct.alphaMultiplier = _selectBox.alpha;
			_selectBox.transform.colorTransform = ct;
			_limbs.x = (_hideRoot)? 0 : cornerX - _style.treeOffset.x;
			_limbs.y = (_hideRoot)? 0 : _style.lineSpacing;
			
			var hideMe:Boolean = _hideRoot && _isRoot;
			_selectBox.visible = _labelText.visible = _iconSprite.visible = !hideMe;
			_switchContainer.visible = _rootLimb._closable && !hideMe;
		}
		
		private const ICON_FOLDER_OPEN:String = "open";
		private const ICON_FOLDER_CLOSE:String = "close";
		private const ICON_FILE:String = "file_";
		/**
		 * アイコン表示更新
		 */
		private function updateIcon():void
		{
			var type:String = (_isFolder)? (_isOpen && numChildLimb)? ICON_FOLDER_OPEN : ICON_FOLDER_CLOSE : ICON_FILE + _icon;
			if (type == _lastIcon && !_isNewStyle) return;
			
			_lastIcon = type;
			_isNewStyle = false;
			
			while (_iconSprite.numChildren)
			{
				_iconSprite.removeChildAt(0);
			}
			
			var bmd:BitmapData;
			if (type == ICON_FOLDER_OPEN)
			{
				bmd = _style.openIcon;
			}
			else if (type == ICON_FOLDER_CLOSE)
			{
				bmd = _style.closeIcon;
			}
			else if (!_icon || !_style.icon[_icon])
			{
				bmd = _style.noIcon;
			}
			else
			{
				bmd = _style.icon[_icon];
			}
			var bmp:Bitmap = new Bitmap(bmd);
			_iconSprite.addChild(bmp);
			bmp.x =  -int(bmp.width / 2);
			bmp.y =  -int(bmp.height / 2);
		}
		
		/**
		 * 指定のTreeLimbがこのTreeLimbオブジェクトの祖先かどうかをチェック
		 * @param	limb
		 * @return
		 */
		public function checkAncestor(limb:TreeLimb):Boolean
		{
			var target:TreeLimb = _parentLimb;
			while (target)
			{
				if (target === limb) return true;
				target = target._parentLimb;
			}
			return false;
		}
		
		/**
		 * 自分より下の階層の矩形サイズを取得する
		 * @return
		 */
		public function getVisibleRect():Rectangle
		{
			var rect:Rectangle = _itemContainer.getBounds(rootLimb);
			if (_isOpen)
			{
				for each(var l:TreeLimb in getChildLimbs())
				{
					rect = rect.union(l.getVisibleRect());
				}
			}
			return rect;
		}
		
		/**
		 * 自分より下の階層の見えているアイテム数を取得する
		 * @return
		 */
		private function getVisibleCount():int
		{
			if (_lastVisibleCount >= 0)
			{
				return _lastVisibleCount;
			}
			_lastVisibleCount = 0;
			if (_itemVisible)
			{
				_lastVisibleCount++;
				if (_isOpen)
				{
					for each(var l:TreeLimb in getChildLimbs())
					{
						_lastVisibleCount += l.getVisibleCount();
					}
				}
			}
			
			return _lastVisibleCount;
		}
		
		/**
		 * 複製
		 * @param	subLimbs	サブフォルダ以下も複製するか
		 * @return
		 */
		public function clone(subLimbs:Boolean = true):TreeLimb
		{
			var newLimb:TreeLimb = new TreeLimb();
			for each(var x:XML in describeType(this).accessor.(@declaredBy.split("::").pop() == "TreeLimb" && @access == "readwrite")) newLimb[x.@name] = this[x.@name];
			newLimb._style = _style;
			if(subLimbs) for each(var l:TreeLimb in getChildLimbs()) newLimb.addLimb(l.clone());
			return newLimb;
		}
		
		/**
		 * 
		 * @param	obj
		 */
		public function parseObject(value:*):void 
		{
			lock();
			
			var parse:Function = function(limb:TreeLimb, data:*):void
			{
				if (data is String || data is Number)
				{
					limb.label += " = " + data;
					return;
				}
				
				for (var k:* in data) 
				{
					var child:TreeLimb = new TreeLimb(String(k), false);
					parse(child, data[k]);
					limb.addLimb(child);
				}
			}
			parse(this, value);
			
			unlock();
		}
		
		/**
		 * このファイル/フォルダのルートからのパスを取得する
		 * @param	delimiter	区切り文字
		 * @return
		 */
		public function getPath(delimiter:String = "/"):String 
		{
			var item:TreeLimb = this;
			var list:Array = [];
			while (item)
			{
				list.unshift(item.label);
				item = item.parentLimb;
			}
			return list.join(delimiter);
		}
		
		/**
		 * 相対パスでTreeLimbを取得する
		 * @param	path
		 * @param	delimiter	区切り文字
		 */
		public function getResolveLimb(path:String, delimiter:String = "/"):TreeLimb 
		{
			if (path.charAt(path.length - 1) == delimiter) path = path.substr(0, path.length - 1);
			var blocks:Array = path.split(delimiter);
			var limb:TreeLimb = this;
			for (var i:int = 0; i < blocks.length; i++) 
			{
				var label:String = blocks[i];
				var n:int = limb.numChildLimb;
				var exsist:Boolean = false;
				for (var j:int = 0; j < n; j++) 
				{
					var tl:TreeLimb = limb.getLimbAt(j);
					if (tl.label == label)
					{
						limb = tl;
						exsist = true;
						break;
					}
				}
				if (!exsist) return null;
			}
			return limb;
		}
		
		public function checkRectVisible(base:DisplayObject, rect:Rectangle):void 
		{
			_visible = rect.intersects(getBounds(base));
			super.visible = _visible && _itemVisible;
		}
		
		/**
		 * 
		 * @param	menu
		 */
		public function setContextMenu(menu:NativeMenu):void 
		{
			_iconSprite.contextMenu = menu;
			_selectBox.contextMenu = menu;
		}
		
	}

}