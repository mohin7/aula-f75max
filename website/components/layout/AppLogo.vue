<script setup lang="ts">
const asset = useAsset()
</script>

<template>
  <span class="inline-flex items-center gap-2.5">
    <img :src="asset('/images/app-icon.webp')" alt="" width="28" height="28" class="size-7 rounded-[7px]" decoding="async">
    <span class="whitespace-nowrap text-[15px] font-semibold tracking-tight text-white">AULA Studio</span>
  </span>
</template>
