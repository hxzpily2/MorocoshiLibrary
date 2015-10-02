package net.morocoshi.components.minimal.layout 
{
	import com.bit101.components.Component;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.graphics.Draw;
	
	/**
	 * フレームレイアウト用セルオブジェクト
	 * 
	 * @author tencho
	 */
	public class LayoutCell extends Component 
	{
		static public const ALIGN_LEFT:String = "left";
		static public const ALIGN_RIGHT:String = "right";
		static public const ALIGN_TOP:String = "top";
		static public const ALIGN_BOTTOM:String = "bottom";
		
		private var _align:String;
		private var _cells:Vector.<Component>;
		private var _style:LayoutStyle;
		private var _margin:Number = 0;
		
		private var isInit:Boolean = false;
		internal var cellIDLink:Object;
		internal var layoutIDLink:Object;
		internal var layoutLink:Dictionary;
		internal var separators:Vector.<LayoutSeparator>;
		private var isVertical:Boolean = false;
		private var cellContainer:Sprite = new Sprite();
		private var dragLine:Sprite;
		private var index:int = 0;
		private var _separatorEnabled:Boolean = false;
		
		internal var borderCanvas:Sprite = new Sprite();
		internal var separatorCanvas:Sprite = new Sprite();
		internal var dragCanvas:Sprite = new Sprite();
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	parent
		 * @param	xpos
		 * @param	ypos	
		 * @param	align	セルの整列方向
		 * @param	separator	セパレータが初期状態で有効か
		 */
		public function LayoutCell(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, align:String = ALIGN_LEFT, separator:Boolean = true)
		{
			_margin = 10;
			_cells = new Vector.<Component>;
			_separatorEnabled = separator;
			separators = new Vector.<LayoutSeparator>;
			cellIDLink = { };
			layoutIDLink = { };
			layoutLink = new Dictionary();
			_style = new LayoutStyle();
			this.align = align;
			super(parent, xpos, ypos);
			isInit = true;
			addChild(cellContainer);
			addChild(borderCanvas);
			addChild(separatorCanvas);
			addChild(dragCanvas);
			borderCanvas.mouseChildren = borderCanvas.mouseEnabled = false;
			separatorCanvas.mouseChildren = separatorCanvas.mouseEnabled = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 整列方向
		 */
		public function get align():String
		{
			return _align;
		}
		
		public function set align(value:String):void
		{
			_align = value;
			isVertical = (_align == ALIGN_BOTTOM || _align == ALIGN_TOP);
		}
		
		public function get style():LayoutStyle
		{
			return _style;
		}
		
		public function set style(value:LayoutStyle):void
		{
			_style = value;
		}
		
		public function get rootCell():LayoutCell
		{
			if (parent && parent.parent && parent.parent is LayoutCell)
			{
				return LayoutCell(parent.parent).rootCell;
			}
			return this;
		}
		
		public function get globalX():Number
		{
			return getGlobalX(0);
		}
		
		public function get globalY():Number
		{
			return getGlobalY(0);
		}
		
		public function get cells():Vector.<Component> 
		{
			return _cells;
		}
		
		override public function set height(value:Number):void 
		{
			clear();
			super.height = value;
			lineUp();
			updateLayout();
		}
		
		override public function set width(value:Number):void 
		{
			clear();
			super.width = value;
			lineUp();
			updateLayout();
		}
		
		public function get margin():Number 
		{
			return _margin;
		}
		
		public function set margin(value:Number):void 
		{
			_margin = value;
		}
		
		public function get separatorEnabled():Boolean 
		{
			return _separatorEnabled;
		}
		
		public function set separatorEnabled(value:Boolean):void 
		{
			_separatorEnabled = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	component	Component
		 * @param	size		*、～px、～％
		 * @param	resize		LayoutData.PERCENT
		 * @return
		 */
		public function addCell(component:Component, size:String = "*", resize:String = null, id:String = ""):Component
		{
			if (!resize) resize = LayoutData.PERCENT;
			return addCellAt(cellContainer.numChildren, component, size, resize, id);
		}
		
		/**
		 * 
		 * @param	component	Component
		 * @param	size		*、～px、～％
		 * @param	resize		LayoutData.PERCENT
		 * @return
		 */
		public function addColorBox(color:uint, alpha:Number = 1, size:String = "*", resize:String = null):Component
		{
			if (!resize) resize = LayoutData.PERCENT;
			var component:Component = new Component();
			var box:Sprite = Create.box(0, 0, 10, 10, color, alpha);
			component.addChild(box);
			component.addEventListener(Event.RESIZE, function(e:Event):void
			{
				box.width = component.width;
				box.height = component.height;
			});
			return addCellAt(cellContainer.numChildren, component, size, resize);
		}
		
		/**
		 * 
		 * @param	i			index
		 * @param	component	Component
		 * @param	size		*、～px、～％
		 * @param	resize		LayoutData.PERCENT
		 * @return
		 */
		public function addCellAt(i:int, component:Component, size:String = "*", resize:String = null, id:String = ""):Component
		{
			if (!resize) resize = LayoutData.PERCENT;
			layoutLink[component] = new LayoutData(size, resize);
			if (id != "")
			{
				cellIDLink[id] = component;
				layoutIDLink[id] = layoutLink[component];
			}
			var separator:LayoutSeparator = new LayoutSeparator();
			separator.enabled = _separatorEnabled;
			separator.cell = this;
			separator.index = index++;
			separators.push(separator);
			_cells.push(component);
			cellContainer.addChildAt(component, i);
			addChild(separator);
			updateSeparatorIndex();
			return component;
		}
		
		public function update():void
		{
			clear();
			lineUp();
			updateLayout();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			clear();
			super.setSize(w, h);
			lineUp();
			updateLayout();
		}
		
		//--------------------------------------------------------------------------
		//
		//  各種情報取得
		//
		//--------------------------------------------------------------------------
		
		public function getLayoutByID(id:String):LayoutData
		{
			var result:LayoutData = layoutIDLink[id];
			if (result != null) return result;
			
			for each(var cell:Component in _cells)
			{
				if (cell is LayoutCell)
				{
					result = LayoutCell(cell).getLayoutByID(id);
					if (result != null) return result;
				}
			}
			return null;
		}
		
		public function getLayoutAt(i:int):LayoutData
		{
			return layoutLink[_cells[i]];
		}
		
		public function getLayout(component:Component):LayoutData
		{
			var result:LayoutData = layoutLink[component];
			if (result != null) return result;
			
			for each(var cell:Component in _cells)
			{
				if (cell is LayoutCell)
				{
					result = LayoutCell(cell).getLayout(component);
					if (result != null) return result;
				}
			}
			return null;
		}
		
		public function getCellByID(id:String):Component
		{
			return cellIDLink[id];
		}
		
		public function getCellAt(i:int):Component
		{
			return _cells[i];
		}
		
		public function getAllCells():Vector.<Component>
		{
			var n:int = _cells.length;
			var list:Vector.<Component> = new Vector.<Component>;
			for (var i:int = 0; i < n; i++) 
			{
				var cmp:Component = _cells[i];
				if (cmp is LayoutCell)
				{
					list = list.concat(LayoutCell(cmp).getAllCells());
				}
				else
				{
					list.push(_cells[i]);
				}
			}
			return list;
		}
		
		public function getGlobalX(local:Number):Number
		{
			if (parent && parent.parent is LayoutCell) return LayoutCell(parent.parent).getGlobalX(local + x);
			else return local + x;
		}
		
		public function getGlobalY(local:Number):Number
		{
			if (parent && parent.parent is LayoutCell) return LayoutCell(parent.parent).getGlobalY(local + y);
			else return local + y;
		}
		
		public function getSeparatorAt(index:int):LayoutSeparator
		{
			return separators[index];
		}
		
		public function addSpace(size:String = "*", resize:* = null, id:String = ""):Component 
		{
			return addCell(new Component(), size, resize, id);
		}
		
		private var backgroundSprite:Sprite;
		private var backgroundPattern:BitmapData;
		
		public function setBackgroundPattern(pattern:BitmapData):Sprite
		{
			if (backgroundSprite != null)
			{
				removeChild(backgroundSprite);
			}
			
			backgroundPattern = pattern;
			backgroundSprite = new Sprite();
			addChildAt(backgroundSprite, 0);
			addEventListener(Event.RESIZE, cell_resizeHandler);
			cell_resizeHandler(null);
			
			return backgroundSprite;
		}
		
		public function setBackgroundColor(rgb:uint, alpha:Number = 1):Sprite 
		{
			if (backgroundSprite != null)
			{
				removeChild(backgroundSprite);
			}
			
			backgroundPattern = null;
			backgroundSprite = Create.box(0, 0, 10, 10, rgb, alpha);
			addChildAt(backgroundSprite, 0);
			addEventListener(Event.RESIZE, cell_resizeHandler);
			cell_resizeHandler(null);
			
			return backgroundSprite;
		}
		
		private function cell_resizeHandler(e:Event):void 
		{
			if (backgroundPattern)
			{
				backgroundSprite.graphics.clear();
				Draw.bitmapFillBox(backgroundSprite.graphics, 0, 0, width, height, backgroundPattern);
			}
			else
			{
				backgroundSprite.width = width;
				backgroundSprite.height = height;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function updateSeparatorIndex():void 
		{
			for (var i:int = 0;  i < separators.length; i++ )
			{
				var spr:LayoutSeparator = separators[i];
				spr.index = i;
			}
		}
		
		internal function stopDragLine():void
		{
			if (!dragLine || !dragLine.parent) return;
			dragLine.parent.removeChild(dragLine);
			dragLine = null;
		}
		
		internal function startDragLine(spr:LayoutSeparator):void 
		{
			var style:LayoutStyle = rootCell.style;
			dragLine = new Sprite();
			dragLine.graphics.beginFill(style.resizingColor, style.resizingAlpha);
			dragLine.graphics.drawRect(0, 0, spr.width, spr.height);
			dragLine.graphics.endFill();
			addChild(dragLine);
		}
		
		internal function moveLine(x:Number, y:Number):void 
		{
			dragLine.x = x;
			dragLine.y = y;
		}
		
		private function clear():void 
		{
			borderCanvas.graphics.clear();
			separatorCanvas.graphics.clear();
		}
		
		protected function updateLayout():void 
		{
		}
		
		/**
		 * 整列
		 */
		private function lineUp():void 
		{
			if (!isInit) return;
			var cnt:int = 0;
			var size:Number = isVertical? _height : _width;
			var param:String = isVertical? "height": "width";
			var param2:String = isVertical? "width" : "height";
			
			var i:int, cmp:Component, n:int = _cells.length - 1;
			var style:LayoutStyle = rootCell.style;
			var b:Number = style.borderSize * 2 + style.separateSize | 0;
			var lengthLink:Dictionary = new Dictionary();
			
			var lastComponent:Component;
			//内部のセルを順に調べる
			for (i = 0; i <= n; i++) 
			{
				cmp = _cells[i];
				
				separators[i].isVertical = !isVertical;
				if (!cmp.visible) continue;
				lastComponent = cmp;
				var l:LayoutData = layoutLink[cmp];
				//セルの幅がAUTOじゃない場合
				if (l.unit != LayoutData.AUTO)
				{
					var px:Number = (l.unit == LayoutData.PIXEL)? l.size : this[param] * 0.01 * l.size | 0;
					size -= px + (separators[i].enabled && i != n? b : 0);
					if (size < 0)
					{
						lengthLink[cmp] = px + size;
						size = 0;
					}
					else
					{
						lengthLink[cmp] = px;
					}
				}
				else
				{
					size -= separators[i].enabled && i != n? b : 0;
					cnt++;
				}
			}
			if (cnt)
			{
				//幅がAUTOだった時に残りの幅を等分する
				var t:Number = size / cnt | 0;
				for (i = 0; i < _cells.length; i++) 
				{
					cmp = _cells[i];
					if (layoutLink[cmp].unit != LayoutData.AUTO) continue;
					lengthLink[cmp] = t;
				}
			}
			
			var d:Number = 0;
			for (i = 0; i <= n; i++) 
			{
				cmp = _cells[i];
				if (!cmp.visible) continue;
				var spr:LayoutSeparator = separators[i];
				if (isVertical)
				{
					cmp.y = d;
					if (lastComponent != cmp)
					{
						cmp.setSize(_width, lengthLink[cmp]);
					}
					else
					{
						cmp.setSize(_width, _height - d);
					}
					spr.y = d + cmp.height;
				}
				else
				{
					cmp.x = d;
					if (lastComponent != cmp)
					{
						cmp.setSize(lengthLink[cmp], _height);
					}
					else
					{
						cmp.setSize(_width - d, _height);
					}
					spr.x = d + cmp.width;
				}
				spr.visible = (i < n && spr.enabled);
				d += cmp[param] + (spr.enabled? b : 0);
				
				if (i != n && spr.enabled)
				{
					if (isVertical)
					{
						spr.draw(_width);
					}
					else
					{
						spr.draw(_height);
					}
				}
			}
		}
		
	}

}