package net.morocoshi.components.minimal.tab 
{
	import com.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.morocoshi.common.graphics.Draw;
	import net.morocoshi.components.minimal.style.Coloration;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class TabBox extends Component 
	{
		public var tabContainer:Sprite;
		public var bgContainer:Sprite;
		public var contentContainer:Sprite;
		public var tabList:Vector.<TabButton>;
		public var contentList:Vector.<Component>;
		
		private var _padding:Number;
		private var _spacing:Number;
		private var _tabHeight:Number;
		private var _paddingTop:Number;
		private var _round:Number;
		private var tabs:Object;
		private var _selectedTab:TabButton;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function TabBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			_padding = 5;
			_paddingTop = 5;
			_spacing = 2;
			_tabHeight = 25;
			_round = 10;
			tabs = { };
			tabList = new Vector.<TabButton>;
			contentList = new Vector.<Component>;
			tabContainer = new Sprite();
			contentContainer = new Sprite();
			bgContainer = new Sprite();
			addChild(bgContainer);
			addChild(tabContainer);
			addChild(contentContainer);
			setSize(600, 400);
		}
		
		//--------------------------------------------------------------------------
		//
		//  取得
		//
		//--------------------------------------------------------------------------
		
		public function getContentAt(i:int):Component
		{
			return getTabAt(i).content;
		}
		
		public function getContentID(id:String):Component 
		{
			return getTabID(id).content;
		}
		
		public function getTabAt(i:int):TabButton
		{
			return tabList[i];
		}
		
		public function getTabID(id:String):TabButton
		{
			return tabs[id];
		}
		
		//--------------------------------------------------------------------------
		//
		//  追加
		//
		//--------------------------------------------------------------------------
		
		public function addTab(text:String, id:String = "", content:Component = null):TabButton
		{
			var tab:TabButton = new TabButton(this, text, id);
			tab.addEventListener(MouseEvent.CLICK, tab_clickHandler);
			tab.content = content || new Component();
			tab.content.visible = false;
			tabList.push(tab);
			contentList.push(tab.content);
			tabContainer.addChild(tab);
			tabs[id] = tab;
			contentContainer.addChild(tab.content);
			update();
			return tab;
		}
		
		//--------------------------------------------------------------------------
		//
		//  選択
		//
		//--------------------------------------------------------------------------
		
		public function selectTabAt(index:int, silent:Boolean = false):void
		{
			_selectedTab = null;
			for (var i:int = 0; i < tabList.length; i++)
			{
				var item:TabButton = tabList[i];
				var select:Boolean = (i == index);
				item.content.visible = item.isActivate = select;
				if (select)
				{
					_selectedTab = item;
				}
			}
			update();
			if (!silent && _selectedTab) notifySelect();
		}
		
		public function selectTab(tab:TabButton, silent:Boolean = false):void 
		{
			_selectedTab = tab;
			for each(var item:TabButton in tabList)
			{
				item.content.visible = item.isActivate = (tab == item);
			}
			update();
			if (!silent && _selectedTab) notifySelect();
		}
		
		public function selectTabID(id:String, silent:Boolean = false):void 
		{
			_selectedTab = null;
			for each(var item:TabButton in tabList)
			{
				var select:Boolean = (id == item.id);
				item.content.visible = item.isActivate = select;
				if (select)
				{
					_selectedTab = item;
				}
			}
			update();
			if (!silent && _selectedTab) notifySelect();
		}
		
		private function notifySelect():void 
		{
			dispatchEvent(new Event(Event.SELECT));
		}
		
		//--------------------------------------------------------------------------
		//
		//  描画処理
		//
		//--------------------------------------------------------------------------
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			update();
		}
		
		public function update():void
		{
			var i:int;
			var n:int;
			var item:TabButton;
			var count:int = 0;
			n = tabList.length;
			
			for (i = 0; i < n; i++)
			{
				item = tabList[i];
				if (item.visible) count++;
			}
			
			var w:int = !count? 0 : (_width - _padding * 2 + _spacing) / count - _spacing;
			var tx:Number = _padding;
			
			tabContainer.y = _paddingTop;
			for (i = 0; i < n; i++)
			{
				item = tabList[i];
				if (!item.visible) continue;
				item.round = _round;
				item.setSize(w, _tabHeight);
				item.x = tx;
				item.y = 0;
				tx += w + _spacing;
			}
			
			var th:Number = _tabHeight + _paddingTop;
			var bh:Number = _height - th;
			
			contentContainer.y = th;
			n = contentList.length;
			for (i = 0; i < n; i++)
			{
				var comp:Component = contentList[i];
				comp.setSize(_width, _height - th);
			}
			
			var g:Graphics = bgContainer.graphics;
			g.clear();
			if (Coloration.TAB_BACKGROUND_ENABLED)
			{
				Draw.gradientBox(g, 0, 0, _width, th, true, 90, [Coloration.TAB_BACKGROUND_TOP, Coloration.TAB_BACKGROUND_BOTTOM], [1, 1]);
			}
			g.beginFill(Coloration.TAB_BORDER);
			g.drawRect(0, th - 1, _width, bh + 1);
			g.beginFill(Coloration.TAB_ACTIVATE);
			g.drawRect(0, th, _width, bh);
		}
		
		public function getTabIndex(tabButton:TabButton):int 
		{
			for (var i:int = 0; i < tabList.length; i++) 
			{
				var tb:TabButton = tabList[i];
				if (tb == tabButton) return i;
			}
			return -1;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function tab_clickHandler(e:MouseEvent):void 
		{
			selectTab(e.currentTarget as TabButton, false);
		}
		
		public function get selectedTab():TabButton 
		{
			return _selectedTab;
		}
		
		public function set selectedTab(value:TabButton):void 
		{
			selectTab(value, false);
		}
		
		public function get tabHeight():Number 
		{
			return _tabHeight;
		}
		
	}

}