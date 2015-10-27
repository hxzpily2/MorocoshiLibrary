package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.CombinedGeometry;
	import net.morocoshi.moja3d.resources.SkinGeometry;
	import net.morocoshi.moja3d.shaders.skin.SkinShader;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * スキンメッシュ
	 * 
	 * @author tencho
	 */
	public class Skin extends Mesh 
	{
		/**
		 * このスキン内にあるボーンオブジェクトのリスト
		 */
		public var bones:Vector.<Bone>;
		
		public var skinShaderList:Vector.<SkinShader>;
		
		public function Skin() 
		{
			super();
			
			updateSeed();
			
			castShadowChildren = false;
			castLightChildren = false;
			reflectChildren = false;
			
			bones = new Vector.<Bone>;
			skinShaderList = new Vector.<SkinShader>;
		}
		/*
		override public function set geometry(value:Geometry):void 
		{
			super.geometry = value;
			skinShader.setGeometry(value);
		}
		*/
		override public function upload(context3D:ContextProxy, hierarchy:Boolean, async:Boolean, complete:Function = null):void 
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
						bones.push(bone);
					}
					task.push(current);
					current = current._next;
				}
			}
			
			var skinShader:SkinShader;
			if (_geometry is CombinedGeometry)
			{
				for each(var geom:SkinGeometry in CombinedGeometry(_geometry).geometries)
				{
					skinShader = new SkinShader();
					skinShader.setSkinGeometry(geom);
					skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
					skinShaderList.push(skinShader);
					//skinGeom.shaderList.updateConstantList();
				}
			}
			else
			{
				skinShader = new SkinShader();
				skinShader.setSkinGeometry(_geometry as SkinGeometry);
				skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
				skinShaderList.push(skinShader);
				//SkinGeometry(_geometry).skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
				//SkinGeometry(_geometry).shaderList.updateConstantList();
			}
			//skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
			//startShaderList.updateConstantList();
			var combinedGeom:CombinedGeometry = geometry as CombinedGeometry;
			if (combinedGeom)
			{
				for each(var surface:Surface in surfaces)
				{
					surface.linkSurfaces(combinedSurfacesList);
				}
			}
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:int):Boolean 
		{
			return super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
		}
		
		override protected function calculate(collector:RenderCollector):void 
		{
			//スキン姿勢の逆行列の計算
			var invertSkin:Matrix3D = _worldMatrix.clone();
			invertSkin.invert();
			for each (var item:SkinShader in skinShaderList) 
			{
				item.updateBoneConstants(invertSkin);
			}
		}
		
	}

}