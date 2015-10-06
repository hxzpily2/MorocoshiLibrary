package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Bone extends Object3D 
	{
		/**ボーンのワールド初期姿勢(___計算簡略化のためにinvertしておきたいけど、今はデバッグで使うのでこのままで)*/
		public var initialMatrix:Matrix3D;
		public var invertSkinMatrix:Matrix3D;
		public var hasWeight:Boolean;
		public var index:int;
		public var renderConstant:AGALConstant;
		public var shadowConstant:AGALConstant;
		public var reflectConstant:AGALConstant;
		public var maskConstant:AGALConstant;
		
		public function Bone() 
		{
			super();
			hasWeight = false;
			initialMatrix = new Matrix3D();
		}
		
		override public function reference():Object3D 
		{
			var object:Bone = new Bone();
			
			referenceProperties(object);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				object.addChild(current.reference());
			}
			
			return object;
		}
		
		override public function clone():Object3D 
		{
			var object:Bone = new Bone();
			
			cloneProperties(object);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				object.addChild(current.clone());
			}
			
			return object;
		}
		
		override public function referenceProperties(target:Object3D):void 
		{
			super.referenceProperties(target);
			
			var bone:Bone = target as Bone;
			bone.index = index;
			bone.hasWeight = hasWeight;
			bone.initialMatrix = initialMatrix.clone();
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var bone:Bone = target as Bone;
			bone.index = index;
			bone.hasWeight = hasWeight;
			bone.initialMatrix = initialMatrix.clone();
		}
		
		public function setConstant(constant:AGALConstant, phase:String):void 
		{
			if (phase == RenderPhase.NORMAL)
			{
				renderConstant = constant;
			}
			if (phase == RenderPhase.MASK)
			{
				maskConstant = constant;
			}
			if (phase == RenderPhase.DEPTH)
			{
				shadowConstant = constant;
			}
			if (phase == RenderPhase.REFLECT)
			{
				reflectConstant = constant;
			}
		}
		
		/**
		 * 姿勢変化時の計算
		 * @param	e
		 */
		override protected function calculate(collector:RenderCollector):void 
		{
			if (invertSkinMatrix == null) return;
			
			var matrix:Matrix3D = renderConstant.matrix;
			matrix.copyFrom(_worldMatrix);
			matrix.prepend(initialMatrix);
			matrix.prepend(invertSkinMatrix);
			if (shadowConstant)
			{
				shadowConstant.matrix = matrix;
			}
			if (maskConstant)
			{
				maskConstant.matrix = matrix;
			}
			if (reflectConstant)
			{
				reflectConstant.matrix = matrix;
			}
		}
		
	}

}