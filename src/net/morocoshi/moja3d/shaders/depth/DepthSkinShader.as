package net.morocoshi.moja3d.shaders.depth 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.objects.Bone;
	import net.morocoshi.moja3d.objects.Skin;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.SkinGeometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DepthSkinShader extends MaterialShader 
	{
		
		public var boneList:Vector.<Bone>;
		private var numBones:int;
		private var skin:Skin;
		private var skinConst:AGALConstant;
		private var depthSkinShader:DepthSkinShader;
		private var geometry:SkinGeometry;
		
		public function DepthSkinShader() 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.BONEINDEX1);
			requiredAttribute.push(VertexAttribute.BONEWEIGHT1);
			
			boneList = new Vector.<Bone>;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		public function setSkinGeometry(geometry:SkinGeometry):void
		{
			this.geometry = geometry;
			updateShaderCode();
		}
		
		/**
		 * 
		 * @param	bones
		 * @param	skin
		 */
		public function initializeBones(bones:Vector.<Bone>, skin:Skin):void
		{
			this.skin = skin;
			boneList.length = 0;
			numBones = bones.length;
			
			super.updateConstants();
			for (var i:int = 0; i < numBones; i++) 
			{
				var bone:Bone = bones[i];
				bone.addConstant(vertexCode.addConstantListFromMatrix("@boneMatrix" + i + ":", new Matrix3D(), true), RenderPhase.SHADOW);
				boneList.push(bone);
			}
			//[0]スキンMatrix定数の開始インデックス
			//[1]4
			skinConst = vertexCode.addConstantsFromArray("@skinData", [0, 4, 0, 0]);
			updateShaderCode();
		}
		
		override public function afterCreateProgram(shaderList:ShaderList):void 
		{
			skinConst.x = shaderList.getVertexConstantIndex("@boneMatrix0:");
		}
		
		override public function getKey():String 
		{
			return "DepthSkinShader:" + geometry.seed;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			if (numBones == 0) return;
			
			vertexConstants.number = true;
			vertexCode.addCode([
				"var $temp",
				"var $index",
				"var $tempPosition",
				"$tempPosition = @0_0_0"
			]);
			
			var boneIndex1:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEINDEX1);
			var boneWeight1:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEWEIGHT1);
			
			var i:int;
			var xyzw:Array = ["x", "y", "z", "w"];
			for (i = 0; i < 4; i++) 
			{
				vertexCode.addCode([
					//使用インデックス＝ボーンインデックス*4+開始インデックス
					"$index.x = " + boneIndex1 + "." + xyzw[i] + " * @skinData.y",
					"$index.x += @skinData.x",
					
					"$temp.xyz = m44($pos, vc[$index.x])",//元の座標を行列変換
					"$temp.xyz *= " + boneWeight1 + "." + xyzw[i],//ウェイトを乗算
					"$tempPosition.xyz += $temp.xyz"
				]);
			}
			
			var bone2:Boolean = geometry.hasAttribute(VertexAttribute.BONEINDEX2) && geometry.hasAttribute(VertexAttribute.BONEWEIGHT2);
			if (bone2)
			{
				var boneIndex2:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEINDEX2);
				var boneWeight2:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEWEIGHT2);
				
				for (i = 0; i < 4; i++)
				{
					vertexCode.addCode([
						//使用インデックス＝ボーンインデックス*4+開始インデックス
						"$index.x = " + boneIndex2 + "." + xyzw[i] + " * @skinData.y",
						"$index.x += @skinData.x",
						
						"$temp.xyzw = m44($pos.xyzw, vc[$index.x])",//元の座標を行列変換
						"$temp.xyz *= " + boneWeight2 + "." + xyzw[i],//ウェイトを乗算
						"$tempPosition.xyz += $temp.xyz"
					]);
				}	
			}
			
			vertexCode.addCode([
				"$pos.xyz = $tempPosition.xyz"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:DepthSkinShader = new DepthSkinShader();
			shader.setSkinGeometry(geometry);
			return shader;
		}
		
	}

}