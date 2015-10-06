package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.shaders.skin.SkinShader;
	
	use namespace moja3d;
	
	/**
	 * スキンメッシュ
	 * 
	 * @author tencho
	 */
	public class Skin extends Mesh 
	{
		private var bones:Vector.<Bone>;
		private var skinShader:SkinShader;
		
		public function Skin() 
		{
			skinShader = new SkinShader();
			
			super();
			
			updateSeed();
			bones = new Vector.<Bone>;
			startShaderList = new ShaderList();
			startShaderList.addShader(skinShader);
		}
		
		override public function set geometry(value:Geometry):void 
		{
			super.geometry = value;
			skinShader.setGeometry(value);
		}
		
		override public function upload(context3D:Context3D, hierarchy:Boolean, async:Boolean, complete:Function = null):void 
		{
			super.upload(context3D, hierarchy, async, complete);
		}
		
		override public function clone():Object3D 
		{
			var skin:Skin = new Skin();
			
			cloneProperties(skin);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				skin.addChild(current.clone());
			}
			
			skin.calculateBones();
			
			return skin;
		}
		
		override public function reference():Object3D 
		{
			var skin:Skin = new Skin();
			
			referenceProperties(skin);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				skin.addChild(current.reference());
			}
			
			skin.calculateBones();
			
			return skin;
		}
		
		public function calculateBones():void
		{
			bones.length = 0;
			var task:Vector.<Object3D> = new <Object3D>[this];
			while (task.length)
			{
				var current:Object3D = task.pop()._children;
				while (current)
				{
					var bone:Bone = current as Bone;
					if (bone && bone.hasWeight)
					{
						if (bones.length <= bone.index)
						{
							bones.length = bone.index + 1;
						}
						if (bones.length < bone.index)
						{
							bones.length = bone.index;
						}
						bones[bone.index] = bone;
					}
					task.push(current);
					current = current._next;
				}
			}
			skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
			startShaderList.updateConstantList();
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:uint):Boolean 
		{
			return super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
		}
		
		override protected function calculate(collector:RenderCollector):void 
		{
			//ボーンの計算
			skinShader.updateBoneConstants();
		}
		
	}

}