package net.morocoshi.components.minimal.layout 
{
	import com.bit101.components.Component;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * フレームレイアウト用セパレータオブジェクト
	 * 
	 * @author tencho
	 */
	public class LayoutSeparator extends Sprite
	{
		public var index:int = 0;
		public var isVertical:Boolean = false;
		public var cell:LayoutCell;
		public var enabled:Boolean = true;
		private var _draggable:Boolean = true;
		private var offset:Number;
		private var min:Number;
		private var max:Number;
		
		public function LayoutSeparator() 
		{
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			draggable = true;
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			offset = isVertical?  -mouseX :  -mouseY;
			if (isVertical)
			{
				min = cell.cells[index].x + cell.globalX;
				max = cell.cells[index + 1].x + cell.cells[index + 1].width - cell.rootCell.style.size + cell.globalX;
			}
			else
			{
				min = cell.cells[index].y + cell.globalY;
				max = cell.cells[index + 1].y + cell.cells[index + 1].height - cell.rootCell.style.size + cell.globalY;
			}
			cell.rootCell.startDragLine(this);
			mouseMoveHandler();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private function mouseMoveHandler(e:MouseEvent = null):void
		{
			var slide:Number = (isVertical)? cell.rootCell.mouseX + offset : cell.rootCell.mouseY + offset;
			if (slide < min) slide = min;
			if (slide > max) slide = max;
			
			if (isVertical) cell.rootCell.moveLine(slide, cell.y);
			else cell.rootCell.moveLine(cell.x, slide);
			
			var layout:LayoutData = cell.layoutLink[cell.cells[index]];
			var xy:Number = isVertical? cell.globalX + cell.cells[index].x : cell.globalY + cell.cells[index].y;
			var wh:Number = isVertical? cell.width : cell.height;
			layout.size = slide - xy;
			if (layout.resize == LayoutData.PERCENT) layout.size *= 100 / wh;
			layout.unit = layout.resize;
			
			var c2:Component = cell.cells[index + 1];
			var layout2:LayoutData = cell.layoutLink[c2];
			var xy2:Number = isVertical? cell.globalX + c2.x + c2.width : cell.globalY + c2.y + c2.height;
			layout2.size = xy2 - slide - cell.rootCell.style.size;
			if (layout2.resize == LayoutData.PERCENT) layout2.size *= 100 / wh;
			layout2.unit = layout2.resize;
		}
		
		private function mouseUpHandler(e:Event):void 
		{
			cell.rootCell.stopDragLine();
			cell.rootCell.update();
			cell.rootCell.dispatchEvent(new Event(Event.RESIZE));
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		public function draw(size:Number):void
		{
			if (!cell) return;
			var style:LayoutStyle = cell.rootCell.style;
			var w:Number = style.size;
			var tx:Number = cell.globalX + x;
			var ty:Number = cell.globalY + y;
			var g:Graphics;
			
			g = cell.rootCell.borderCanvas.graphics;
			g.beginFill(style.borderColor);
			
			if (isVertical)
			{
				g.drawRect(tx, ty, w, size);
				setSize(w, size);
			}
			else
			{
				g.drawRect(tx, ty, size, w);
				setSize(size, w);
			}
			
			g = cell.rootCell.separatorCanvas.graphics;
			g.beginFill(style.separateColor);
			
			if (isVertical)
				g.drawRect(tx + style.borderSize, ty - 1, style.separateSize, size + 2);
			else
				g.drawRect(tx - 1, ty + style.borderSize, size + 2, style.separateSize);
		}
		
		public function get draggable():Boolean { return _draggable; }
		public function set draggable(value:Boolean):void 
		{
			buttonMode = _draggable = value;
		}
		
		public function setSize(w:Number, h:Number):void
		{
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, w, h);

		}
		
	}

}