package net.morocoshi.moja3d.agal 
{
	/**
	 * 各シェーダー内で使う共通定数を決める。trueになっていると使われる
	 * 
	 * @author tencho
	 */
	public class UsingConstants 
	{
		public var modelMatrix:Boolean = false;
		public var viewMatrix:Boolean = false;
		public var projMatrix:Boolean = false;
		public var cameraPosition:Boolean = false;
		public var viewSize:Boolean = false;
		public var lights:Boolean = false;
		public var ambient:Boolean = false;
		public var number:Boolean = false;
		public var clipping:Boolean = false;
		public var shadow:Boolean = false;
		
		public function UsingConstants() 
		{
		}
		
		public function clear():void 
		{
			modelMatrix = false;
			viewMatrix = false;
			projMatrix = false;
			cameraPosition = false;
			viewSize = false;
			lights = false;
			ambient = false;
			number = false;
			clipping = false;
			shadow = false;
		}
		
		public function attach(constants:UsingConstants):void 
		{
			modelMatrix = modelMatrix || constants.modelMatrix;
			viewMatrix = viewMatrix || constants.viewMatrix;
			projMatrix = projMatrix || constants.projMatrix;
			cameraPosition = cameraPosition || constants.cameraPosition;
			viewSize = viewSize || constants.viewSize;
			lights = lights || constants.lights;
			ambient = ambient || constants.ambient;
			number = number || constants.number;
			clipping = clipping || constants.clipping;
			shadow = shadow || constants.shadow;
		}
		
		public function clone():UsingConstants 
		{
			var result:UsingConstants = new UsingConstants();
			result.modelMatrix = modelMatrix;
			result.projMatrix = projMatrix;
			result.viewMatrix = viewMatrix;
			result.cameraPosition = cameraPosition;
			result.viewSize = viewSize;
			result.lights = lights;
			result.ambient = ambient;
			result.number = number;
			result.clipping = clipping;
			result.shadow = shadow;
			return result;
		}
		
	}

}