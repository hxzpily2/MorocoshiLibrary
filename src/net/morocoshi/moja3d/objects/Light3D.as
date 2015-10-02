package net.morocoshi.moja3d.objects 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Light3D extends Object3D 
	{
		public var r:Number;
		public var g:Number;
		public var b:Number;
		public var intensity:Number;
		public var specularPower:Number;
		public var autoShadowBounds:Boolean;
		moja3d var _mainShadow:Shadow;
		moja3d var _wideShadow:Shadow;
		
		public function Light3D(rgb:uint, intensity:Number, specularPower:Number = 1) 
		{
			super();
			
			autoShadowBounds = !true;
			this.intensity = intensity;
			this.specularPower = specularPower;
			setColor(rgb);
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:uint):Boolean 
		{
			var success:Boolean = super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
			if (success)
			{
				//ライト収集（デプス時以外）
				var phase:String = collector.renderPhase;
				if (phase != RenderPhase.DEPTH && phase != RenderPhase.LIGHT)
				{
					collector.addLight3D(this);
				}
			}
			return success;
		}
		
		override public function lookAt3D(point:Vector3D, upAxis:Vector3D = null):void 
		{
			TransformUtil.lookAt3D(matrix, point, "+z", "+y", upAxis, true);
			matrix = _matrix;
		}
		
		override public function lookAtXYZ(x:Number, y:Number, z:Number, upAxis:Vector3D = null):void 
		{
			TransformUtil.lookAtXYZ(matrix, x, y, z, "+z", "+y", upAxis, false);
			matrix = _matrix;
		}
		
		override public function reference():Object3D 
		{
			var result:Light3D = new Light3D(getColor(), intensity, specularPower);
			referenceProperties(result);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				result.addChild(current.reference());
			}
			
			return result;
		}
		
		override public function clone():Object3D 
		{
			var result:Light3D = new Light3D(getColor(), intensity, specularPower);
			cloneProperties(result);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				result.addChild(current.clone());
			}
			
			return result;
		}
		
		override public function referenceProperties(target:Object3D):void 
		{
			var light:Light3D = target as Light3D;
			super.referenceProperties(light);
			light.r = r;
			light.g = g;
			light.b = b;
			light.intensity = intensity;
			light.specularPower = specularPower;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			var light:Light3D = target as Light3D;
			super.cloneProperties(target);
			light.r = r;
			light.g = g;
			light.b = b;
			light.intensity = intensity;
			light.specularPower = specularPower;
		}
		
		public function getColor():uint
		{
			var rgb:uint = (r * 0xff << 16) | (g * 0xff << 8) | (b * 0xff);
			return rgb;
		}
		
		public function setColor(rgb:uint):void 
		{
			r = (rgb >>> 16 & 0xff) / 0xff;
			g = (rgb >>> 8 & 0xff) / 0xff;
			b = (rgb & 0xff) / 0xff;
		}
		
		public function get mainShadow():Shadow 
		{
			return _mainShadow;
		}
		
		public function set mainShadow(value:Shadow):void 
		{
			if (_mainShadow)
			{
				_mainShadow.remove();
			}
			_mainShadow = value;
			addChild(_mainShadow);
		}
		
		public function get wideShadow():Shadow 
		{
			return _wideShadow;
		}
		
		public function set wideShadow(value:Shadow):void 
		{
			if (_wideShadow)
			{
				_wideShadow.remove();
			}
			_wideShadow = value;
			addChild(_wideShadow);
		}
		
		/*
		override protected function calculate():void 
		{
			super.calculate();
			
			//影の姿勢をライトに合わせる
			if (shadow && shadow.parent == null)
			{
				addChild(shadow);
				//shadow._worldMatrix.copyRawDataFrom(_worldMatrix.rawData);
				//shadow.calculateMatrixOrder = false;
			}
			if (wideShadow)
			{
				wideShadow._worldMatrix.copyRawDataFrom(_worldMatrix.rawData);
				wideShadow.calculateMatrixOrder = false;
			}
		}
		*/
	}

}