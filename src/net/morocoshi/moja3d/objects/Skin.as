package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.bounds.BoundingBox;
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
		
		moja3d var skinShaderList:Vector.<SkinShader>;
		/**メッシュ変形前の境界ボックス*/
		private var rawBounds:BoundingBox;
		
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
		
		override public function calculateBounds():void 
		{
			super.calculateBounds();
			rawBounds = boundingBox.clone();
		}
		
		/**
		 * スキンメッシュの現在の姿勢で境界ボックスを更新する。ボーンの初期姿勢からのずれで計算するため実際のメッシュより大きく設定される傾向にあります。
		 */
		public function updateSkinBounds():void
		{
			var rawMin:Vector3D = rawBounds.getMinPoint();
			var rawMax:Vector3D = rawBounds.getMaxPoint();
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			var skinMatrix:Matrix3D = worldMatrix.clone();
			skinMatrix.invert();
			for each(var bone:Bone in bones)
			{
				var m:Matrix3D = bone.worldMatrix.clone();
				m.append(skinMatrix);
				m.prepend(bone.initialMatrix);
				var min:Vector3D = m.transformVector(rawMin.clone());
				var max:Vector3D = m.transformVector(rawMax.clone());
				if (minX > min.x) minX = min.x;
				if (minY > min.y) minY = min.y;
				if (minZ > min.z) minZ = min.z;
				if (minX > max.x) minX = max.x;
				if (minY > max.y) minY = max.y;
				if (minZ > max.z) minZ = max.z;
				if (maxX < min.x) maxX = min.x;
				if (maxY < min.y) maxY = min.y;
				if (maxZ < min.z) maxZ = min.z;
				if (maxX < max.x) maxX = max.x;
				if (maxY < max.y) maxY = max.y;
				if (maxZ < max.z) maxZ = max.z;
			}
			boundingBox.minX = minX;
			boundingBox.minY = minY;
			boundingBox.minZ = minZ;
			boundingBox.maxX = maxX;
			boundingBox.maxY = maxY;
			boundingBox.maxZ = maxZ;
			updateBounds();
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.referenceProperties(target);
			
			var skin:Skin = target as Skin;
			skin.rawBounds = rawBounds? rawBounds.clone() : null;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var skin:Skin = target as Skin;
			skin.rawBounds = rawBounds? rawBounds.clone() : null;
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
			
			skin.collectBones();
			
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
			
			skin.collectBones();
			
			return skin;
		}
		
		/**
		 * スキン内にあるボーンオブジェクトを収集して必要なシェーダーを生成する
		 */
		public function collectBones():void
		{
			bones.length = 0;
			skinShaderList.length = 0;
			
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
				}
			}
			else
			{
				skinShader = new SkinShader();
				skinShader.setSkinGeometry(_geometry as SkinGeometry);
				skinShader.initializeBones(bones, this, RenderPhase.NORMAL);
				skinShaderList.push(skinShader);
			}
			var combinedGeom:CombinedGeometry = geometry as CombinedGeometry;
			if (combinedGeom)
			{
				for each(var surface:Surface in surfaces)
				{
					surface.linkSurfaces(combinedSurfacesList);
				}
			}
		}
		
		private var invertSkin:Matrix3D = new Matrix3D();
		override protected function calculate(collector:RenderCollector):void 
		{
			//スキン姿勢の逆行列の計算
			invertSkin.copyFrom(_worldMatrix);
			invertSkin.invert();
			
			for each (var item:SkinShader in skinShaderList) 
			{
				item.updateBoneConstants(invertSkin);
			}
		}
		
	}

}