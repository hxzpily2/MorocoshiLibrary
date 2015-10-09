package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import flash.utils.getQualifiedClassName;
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
		private var tempMatrix:Matrix3D;
		/**ボーンのワールド初期姿勢(___計算簡略化のためにinvertしておきたいけど、今はデバッグで使うのでこのままで)*/
		public var initialMatrix:Matrix3D;
		public var invertSkinMatrix:Matrix3D;
		public var hasWeight:Boolean;
		public var index:int;
		public var renderConstants:Vector.<AGALConstant>;
		public var shadowConstants:Vector.<AGALConstant>;
		public var reflectConstants:Vector.<AGALConstant>;
		public var maskConstants:Vector.<AGALConstant>;
		
		public function Bone() 
		{
			super();
			hasWeight = false;
			tempMatrix = new Matrix3D();
			initialMatrix = new Matrix3D();
			renderConstants = new Vector.<AGALConstant>;
			shadowConstants = new Vector.<AGALConstant>;
			reflectConstants = new Vector.<AGALConstant>;
			maskConstants = new Vector.<AGALConstant>;
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
		
		public function addConstant(constant:AGALConstant, phase:String):void 
		{
			if (phase == RenderPhase.NORMAL)
			{
				renderConstants.push(constant);
			}
			if (phase == RenderPhase.MASK)
			{
				maskConstants.push(constant);
			}
			if (phase == RenderPhase.DEPTH)
			{
				shadowConstants.push(constant);
			}
			if (phase == RenderPhase.REFLECT)
			{
				reflectConstants.push(constant);
			}
		}
		
		/**
		 * 姿勢変化時の計算
		 * @param	e
		 */
		override protected function calculate(collector:RenderCollector):void 
		{
			if (invertSkinMatrix == null) return;
			
			tempMatrix.copyFrom(_worldMatrix);
			tempMatrix.prepend(initialMatrix);
			tempMatrix.prepend(invertSkinMatrix);
			
			var constant:AGALConstant;
			for each (constant in renderConstants)
			{
				constant.matrix = tempMatrix;
			}
			for each (constant in shadowConstants) constant.matrix = tempMatrix;
			for each (constant in maskConstants) constant.matrix = tempMatrix;
			for each (constant in reflectConstants) constant.matrix = tempMatrix;
		}
		
		override public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " index=" + index + ", " + name + "]";
		}
		
	}

}