package net.morocoshi.common.collision.plane.wallData
{
	import flash.geom.Rectangle;
	
	/**
	 * LineWallDataとCircleWallDataの基底インターフェース
	 * あくまで外部からのデータ追加用型。
	 * Collision2DWorld内部で必要な機能などは、別の型で実装し、初期化時にパースする
	 * 
	 * @author	tencho
	 */
	public interface IWallData
	{
		function get type():int;
	}
	
}
