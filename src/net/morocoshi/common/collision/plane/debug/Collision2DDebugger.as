package net.morocoshi.common.collision.plane.debug
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import net.morocoshi.common.collision.plane.CollideData;
	import net.morocoshi.common.collision.plane.Collision2DWorld;
	import net.morocoshi.common.collision.plane.collisions.BaseCollision;
	import net.morocoshi.common.collision.plane.collisions.CollisionType;
	import net.morocoshi.common.collision.plane.collisions.LineCollision;
	import net.morocoshi.common.collision.plane.units.CollisionUnit;
	import net.morocoshi.common.collision.plane.units.PolygonLine;
	
	/**
	 * コリジョンを描画するデバッグ用キャンバス
	 * 
	 * @author tencho
	 */
	public class Collision2DDebugger
	{
		public var sprite:Sprite = new Sprite();
		private var unitSprite:Dictionary;
		private var _drawSweepRect:Boolean = false;
		private var _drawCollidePoint:Boolean = false;
		private var _wallCanvas:Sprite = new Sprite();
		private var _unitCanvas:Sprite = new Sprite();
		private var _world:Collision2DWorld;
		private var _colors:Array = [0xAA0000, 0x00AA00, 0x0000FF, 0xFF00FF, 0xDDDD00, 0x00DDDD, 0xFF8000, 0x666666, 0x503E8E];
		
		public function Collision2DDebugger()
		{
			unitSprite = new Dictionary();
			sprite.addChild(_wallCanvas);
			sprite.addChild(_unitCanvas);
			_wallCanvas.cacheAsBitmap = true;
		}
		/**移動コリジョン矩形を描画する*/
		public function get drawSweepRect():Boolean 
		{
			return _drawSweepRect;
		}
		
		public function set drawSweepRect(value:Boolean):void 
		{
			_drawSweepRect = value;
		}
		
		/**コリジョンの衝突点を描画する*/
		public function get drawCollidePoint():Boolean 
		{
			return _drawCollidePoint;
		}
		
		public function set drawCollidePoint(value:Boolean):void 
		{
			_drawCollidePoint = value;
		}
		
		/**
		 * Collision2DWorldを指定して初期化
		 * @param	world
		 */
		public function init(world:Collision2DWorld):void
		{
			removeAllUnits();
			_world = world;
			drawWalls();
		}
		
		private function removeAllUnits():void 
		{
			for each(var sp:Sprite in unitSprite)
			{
				_unitCanvas.removeChild(sp);
			}
		}
		
		/**
		 * 壁を描画する
		 */
		public function drawWalls():void
		{
			var g:Graphics = _wallCanvas.graphics;
			g.clear();
			g.lineStyle(1, 0x000000);
			for each(var c:BaseCollision in _world.collisions)
			{
				if (c.type == CollisionType.LINE)
				{
					var line:LineCollision = c as LineCollision;
					g.moveTo(line.origin.x, line.origin.y);
					g.lineTo(line.end.x, line.end.y);
				}
			}
		}
		
		/**
		 * ユニットを描画する
		 */
		public function drawUnits():void
		{
			var ug:Graphics = _unitCanvas.graphics;
			ug.clear();
			for each(var u:CollisionUnit in _world.units)
			{
				if (!unitSprite[u])
				{
					u.addEventListener(Event.REMOVED, unit_removeHandler);
					unitSprite[u] = _unitCanvas.addChild(new Sprite()) as Sprite;
				}
				var sp:Sprite = unitSprite[u];
				
				var rgb:uint = _colors[u.index % _colors.length];
				sp.x = u.x;
				sp.y = u.y;
				sp.rotation = u.rotation / Math.PI * 180;
				var g:Graphics = sp.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(rgb, 0.5);
				g.drawCircle(0, 0, u.nururiRadius);
				g.endFill();
				if (u.exclusion)
				{
					g.lineStyle(1, 0xFFFFFF);
					g.moveTo(0, -u.nururiRadius);
					g.lineTo(0, u.nururiRadius);
				}
				if (u._polygon)
				{
					g.lineStyle(0, 0x000000);
					for each(var line:PolygonLine in u._polygon.lineList)
					{
						g.moveTo(line.x1, line.y1);
						g.lineTo(line.x2, line.y2);
					}
				}
				g.lineStyle(1, rgb);
				g.drawCircle(0, 0, u.radius);
				
				//衝突点
				if (_drawCollidePoint)
				{
					for each(var cd:CollideData in u.collideList)
					{
						ug.lineStyle();
						ug.beginFill(0xFF0000, 1);
						cd.calculateCollidePoint();
						ug.drawCircle(cd.collideX, cd.collideY, 3);
					}
					ug.endFill();					
				}
				//コリジョン判定用矩形
				if (_drawSweepRect)
				{
					ug.lineStyle(1, 0x80AAFF, 1);
					ug.drawRect(u.sweepRect.x, u.sweepRect.y, u.sweepRect.width, u.sweepRect.height);
				}
			}
		}
		
		private function unit_removeHandler(e:Event):void 
		{
			var sp:Sprite = unitSprite[e.currentTarget as CollisionUnit];
			if (sp.parent) sp.parent.removeChild(sp);
		}
		
	}

}