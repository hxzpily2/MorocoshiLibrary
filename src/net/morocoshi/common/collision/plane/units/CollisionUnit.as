package net.morocoshi.common.collision.plane.units
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.morocoshi.common.collision.plane.CollideData;
	import net.morocoshi.common.partitioning.quadtree.TreeData;
	
	/**
	 * キャラクタ用の円コリジョン
	 * 
	 * @author	tencho
	 */
	public class CollisionUnit extends EventDispatcher
	{
		public var _x:Number;
		public var _y:Number;
		public var _rotation:Number;
		public var _index:int;
		public var _enabled:Boolean;
		public var _radius:Number;
		public var _polygonRadius:Number;
		public var _maxRadius:Number;
		public var _nururiRadius:Number;
		public var _nururiRate:Number;
		public var _exclusion:Boolean;
		public var _fix:Boolean;
		public var _removed:Boolean;
		public var _collideList:Vector.<CollideData> = new Vector.<CollideData>;
		public var _polygon:PolygonCollision;
		public var wallTreeData:TreeData;
		public var unitTreeData:TreeData;
		
		/**一時移動量*/
		public var _velocity:Point = new Point();
		/**初期移動量*/
		public var _fVelocity:Point = new Point();
		/**移動範囲も含めたコリジョン矩形*/
		public var _sweepRect:Rectangle = new Rectangle();
		
		/**
		 * コンストラクタ
		 * @param	x	初期位置のX座標
		 * @param	y	初期位置のY座標
		 * @param	radius	壁との衝突判定に使う初期の半径
		 * @param	nururiRadius	ぬるり処理に使う初期の半径
		 * @param	nururiRate	ぬるり処理で押す力（0～）。大きい方が相手を強く押し出す
		 * @param	exclusion	重なっているユニットを強制的に排他する。ボスモンスターなど
		 * @param	fix	他のユニットに絶対に押されない
		 */
		public function CollisionUnit(x:Number, y:Number, radius:Number, nururiRadius:Number, nururiRate:Number, exclusion:Boolean, fix:Boolean)
		{
			_x = x;
			_y = y;
			_rotation = 0;
			_enabled = true;
			_radius = _polygonRadius = radius;
			_nururiRadius = nururiRadius;
			_nururiRate = nururiRate;
			_exclusion = exclusion;
			_fix = fix;
			wallTreeData = new TreeData(this);
			unitTreeData = new TreeData(this);
			checkRadius();
			_updateRect();
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**壁との衝突判定に使う半径*/
		public function get radius():Number 
		{
			return _radius;
		}
		
		public function set radius(value:Number):void 
		{
			_radius = value;
			checkRadius();
		}
		
		/**最終移動位置のX座標*/
		public function get x():Number 
		{
			return _x;
		}
		
		/**最終移動位置のY座標*/
		public function get y():Number 
		{
			return _y;
		}
		
		/**コリジョンが有効か*/
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		/**ぬるり処理に使う半径*/
		public function get nururiRadius():Number 
		{
			return _nururiRadius;
		}
		
		public function set nururiRadius(value:Number):void 
		{
			_nururiRadius = value;
		}
		
		/**重なっているユニットを強制的に排他する。ボスモンスターなど*/
		public function get exclusion():Boolean 
		{
			return _exclusion;
		}
		
		public function set exclusion(value:Boolean):void 
		{
			_exclusion = value;
		}
		
		/**ユニットのインデックス*/
		public function get index():int 
		{
			return _index;
		}
		
		/**他のユニットに絶対に押されない*/
		public function get fix():Boolean 
		{
			return _fix;
		}
		
		public function set fix(value:Boolean):void 
		{
			_fix = value;
		}
		
		/**ぬるり処理で押す力（0～）。大きい方が相手を強く押し出す*/
		public function get nururiRate():Number 
		{
			return _nururiRate;
		}
		
		public function set nururiRate(value:Number):void 
		{
			_nururiRate = value;
		}
		
		/**移動範囲も含めたコリジョン矩形*/
		public function get sweepRect():Rectangle 
		{
			return _sweepRect;
		}
		
		/**衝突データのリスト*/
		public function get collideList():Vector.<CollideData> 
		{
			return _collideList;
		}
		
		/**ユニットの回転角（ラジアン角）*/
		public function get rotation():Number 
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			_rotation = value;
		}
		
		/**
		 * ワールドから既に削除されているか
		 */
		public function get removed():Boolean 
		{
			return _removed;
		}
		
		//--------------------------------------------------------------------------
		//
		//  コリジョン形状の設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パスデータを渡して多角形コリジョンを設定する。このコリジョンは排他処理にだけ使われる。
		 * @param	pointList
		 */
		public function setPolygonCollision(pointList:Vector.<Number>):void 
		{
			_polygon = new PolygonCollision();
			_polygon.setPointList(pointList);
			_polygonRadius = _polygon.radias;
			checkRadius();
		}
		
		//--------------------------------------------------------------------------
		//
		//  移動処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 移動したい目的移動量を設定する
		 * （現在のvelocityを上書きする）
		 * 
		 * @param vx x座標方向の移動量
		 * @param vy y座標方向の移動量
		 */
		public function setVelocity(x:Number, y:Number):void
		{
			_velocity.x = x;
			_velocity.y = y;
		}
		
		/**
		 * 移動したい目的移動量を加算する
		 * （現在のvelocityに加算する）
		 * 
		 * @param vx x座標方向の移動量
		 * @param vy y座標方向の移動量
		 */
		public function addVelocity(x:Number, y:Number):void
		{
			_velocity.x += x;
			_velocity.y += y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  動作があやしい機能（要検証）
		//
		//--------------------------------------------------------------------------
		
		/**
		 * (※要検証)
		 * 壁を無視して移動させる
		 * 
		 * @param x 目的地のx座標
		 * @param y 目的地のy座標
		 */
		public function jump(x:Number, y:Number):void
		{
			_x = x;
			_y = y;
			_velocity.x = _velocity.y = 0;
		}
		
		/**
		 * (※要検証)
		 * 指定位置まで移動させる為の目的移動量を目的地座標で設定する
		 * （現在のvelocityを上書きする）
		 * 
		 * @param x 目的地のx座標
		 * @param y 目的地のy座標
		 */
		public function moveTo(x:Number, y:Number):void
		{
			_velocity.x = x - _x;
			_velocity.y = y - _y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部で使う関数
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 多角形の半径とコリジョンの半径で大きい方を交差判定絞り込み用に使う
		 */
		private function checkRadius():void 
		{
			_maxRadius = (_polygon && _polygonRadius > _radius)? _polygonRadius : _radius;
		}
		
		/**
		 * ワールド側から削除された事が通知される
		 */
		public function _removeFromWorld():void 
		{
			dispatchEvent(new Event(Event.REMOVED));
			_removed = true;
		}
		
		/**
		 * ワールド側から追加された事が通知される
		 */
		public function _addToWorld():void 
		{
			dispatchEvent(new Event(Event.ADDED));
			_removed = false;
		}
		
		/**
		 * コリジョン座標を確定して速度を0にする
		 */
		public function _fixPoint():void 
		{
			_x += _velocity.x;
			_y += _velocity.y;
			_velocity.x = _velocity.y = 0;
		}
		
		/**
		 * 移動範囲も考慮したコリジョン矩形を更新する
		 */
		public function _updateRect():void 
		{
			var vx:Number = _velocity.x;
			var vy:Number = _velocity.y;
			_sweepRect.x = _x - _maxRadius + ((vx > 0)? 0 : vx);
			_sweepRect.y = _y - _maxRadius + ((vy > 0)? 0 : vy);
			_sweepRect.width = _maxRadius * 2 + ((vx > 0)? vx : -vx);
			_sweepRect.height = _maxRadius * 2 + ((vy > 0)? vy : -vy);
			wallTreeData.setRect(_sweepRect.x, _sweepRect.y, _sweepRect.width, _sweepRect.height);
			unitTreeData.setRect(_sweepRect.x, _sweepRect.y, _sweepRect.width, _sweepRect.height);
		}
		
		/**
		 * 初期移動ベクトルを保存する
		 */
		public function _saveVelocity():void 
		{
			_fVelocity.x = _velocity.x;
			_fVelocity.y = _velocity.y;
		}
		
	}

}