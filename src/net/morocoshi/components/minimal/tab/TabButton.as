package net.morocoshi.components.minimal.tab 
{
	import com.bit101.components.Component;
	import com.bit101.components.Label;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.morocoshi.components.minimal.style.Coloration;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TabButton extends Component 
	{
		public var content:Component;
		public var id:String;
		private var isReady:Boolean = false;
		private var _isActivate:Boolean;
		private var box:TabBox;
		private var base:Sprite;
		private var label:Label;
		private var _text:String;
		private var _round:Number;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function TabButton(box:TabBox, text:String, id:String) 
		{
			super();
			_round = 4;
			this.id = id;
			base = new Sprite();
			label = new Label();
			label.addEventListener(Event.RESIZE, label_changeHandler);
			label.text = _text = text;
			addChild(base);
			addChild(label);
			this.box = box;
			isReady = true;
			_isActivate = false;
			blendMode = BlendMode.LAYER;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			label.text = _text = value;
		}
		
		public function get isActivate():Boolean 
		{
			return _isActivate;
		}
		
		public function set isActivate(value:Boolean):void 
		{
			_isActivate = value;
		}
		
		public function get index():int
		{
			var tab:TabBox = parent.parent as TabBox;
			if (tab)
			{
				return tab.getTabIndex(this);
			}
			return -1;
		}
		
		public function get round():Number 
		{
			return _round;
		}
		
		public function set round(value:Number):void 
		{
			_round = value;
			update();
		}
		
		//--------------------------------------------------------------------------
		//
		//  描画処理
		//
		//--------------------------------------------------------------------------
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			box.update();
		}
		
		public function update():void
		{
			setSize(_width, _height);
		}
		
		private function updateLabel():void 
		{
			var lx:int = (_width - label.width) / 2 | 0;
			if (lx < 2) lx = 2;
			label.x = lx;
			label.y = Math.max(1, (_height - label.height) / 2 | 0);
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (!isReady) return;
			if (w < 3)
			{
				alpha = 0;
				return;
			}
			alpha = 1;
			var round1:int = _round;
			var round2:int = round1 - 1;
			var bh:int = h - round1;
			
			var g:Graphics = base.graphics;
			g.clear();
			g.beginFill(Coloration.TAB_BORDER, 1);
			g.drawRoundRect(0, 0, w, round1 * 2, round1, round1);
			g.beginFill(Coloration.TAB_BORDER, 1);
			g.drawRect(0, round1, w, bh);
			var rgb:uint = _isActivate? Coloration.TAB_ACTIVATE : Coloration.TAB_DEACTIVATE;
			g.beginFill(rgb, 1);
			g.drawRoundRect(1, 1, w - 2, round2 * 2, round2, round2);
			g.beginFill(rgb, 1);
			g.drawRect(1, round1, w - 2, bh);
			
			updateLabel();
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function label_changeHandler(e:Event):void 
		{
			updateLabel();
		}
		
	}

}